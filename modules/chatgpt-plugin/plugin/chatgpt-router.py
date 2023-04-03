# Copyright 2023 TIOTH LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License

import os
import boto3
import openai
import datetime
import time

# dynamodb_client used globally
dynamodb_client = boto3.client('dynamodb')
message_cache_expiration_in_hours = int(os.environ['MESSAGE_CACHE_EXPIRATION_IN_HOURS'])
chatgpt_model = os.environ['CHATGPT_MODEL']


#
# Call openai chat api sending messages for a chat response
#
def route_to_chatgpt(messages):
    openai.api_key = os.environ['OPENAI_API_KEY']
    res = openai.ChatCompletion.create(
        model=chatgpt_model,
        messages=messages
    )
    return res


#
# Add a specified openai message to dynamodb cache for the given user
#
def add_message_to_dynamodb(userid, message):
    expiration_time = datetime.datetime.today() + datetime.timedelta(hours=message_cache_expiration_in_hours)
    expiry_datetime = int(time.mktime(expiration_time.timetuple()))
    try:
        dynamodb_client.put_item(
            TableName=os.environ['DYNAMODB_USER_MESSAGE_CACHE'],
            Item={
                'userid': {'S': userid },
                'role': {'S': message["role"]},
                'content': {'S': message["content"]},
                'messageTimeout': {'N': str(expiry_datetime)}
            })
    except Exception as e:
        print('Exception: ', e)


#
# obtain the current list of messages for a given userid. this is the context of
# the current openai chat conversation and will be used as input to the openai chat request.
#
def get_past_message_list_from_dynamodb(userid):
    try:
        response = dynamodb_client.query(
            TableName=os.environ['DYNAMODB_USER_MESSAGE_CACHE'],
            KeyConditionExpression='userid = :userid',
            ExpressionAttributeValues={
                ':userid': {'S': userid}
            }
        )
        past_messages = []
        for item in response['Items']:
            message = {"role": item["role"]["S"], "content": item["content"]['S']}
            past_messages.append(message)
        return past_messages
    except Exception as e:
        print('Exception: ', e)


#
# lambda event handler that starts processing
#
def lambda_handler(event: object, context: object) -> object:
    print(event)
    try:
        qnabot_event = event["req"]["_event"]
    except Exception as e:
        qnabot_event = None

    if qnabot_event is None:
        print("route based reqeust")
        past_messages = get_past_message_list_from_dynamodb(event["req"]["userId"])
        message = {
                "role": "user",
                "content": event["req"]["inputText"]
            }
        add_message_to_dynamodb(event["req"]["userId"], message)
        past_messages.append(message)
        res = route_to_chatgpt(past_messages)
        for choice in res["choices"]:
            add_message_to_dynamodb(event["req"]["userId"], choice["message"])

        print(res["choices"][0]["message"]["content"])
        response = {
            "response": "message",
            'status': 200,
            'message': res["choices"][0]["message"]["content"],
            "sessionAttributes": {
                "appContext": {
                    "altMessages": {
                        "markdown": res["choices"][0]["message"]["content"]
                    }
                }
            }
        }
    else:
        print("qnabot lambda code hook event")
        user_id = event["req"]["_userInfo"]["UserId"]
        past_messages = get_past_message_list_from_dynamodb(user_id)
        message = {
            "role": "user",
            "content": event["req"]["_event"]["inputTranscript"]
        }
        add_message_to_dynamodb(user_id, message)
        past_messages.append(message)
        res = route_to_chatgpt(past_messages)
        for choice in res["choices"]:
            add_message_to_dynamodb(user_id, choice["message"])
        print(res["choices"][0]["message"]["content"])
        response = event
        response['res']['message'] += " " + res["choices"][0]["message"]["content"]
        response['res']['session']['appContext']['altMessages']['markdown'] += " " + res["choices"][0]["message"]["content"]
        if "card" not in response["res"]:
            response["res"]["card"] = {
                "send": True,
                "title": "options",
                "text": "",
                "url": "",
                "buttons": []
            }
        if "buttons" not in response["res"]["card"]:
            response["res"]["card"]["buttons"] = []
        btn = {
            "text": "Yes",
            "value": response["res"]["result"]["args"][0]
        }
        response["res"]["card"]["buttons"].append(btn)

    print(response)
    return response

