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
secretsmanager_client = boto3.client('secretsmanager')
embedding_model = os.environ['EMBEDDING_MODEL']


# function to obtain openai api key from secrets manager
def get_secret(secret_name):
    print("getting secret for " + secret_name)
    response = secretsmanager_client.get_secret_value(SecretId=secret_name)
    secret = response['SecretString']
    return secret


#
# Call openai chat api sending messages for a chat response
#
def get_embeddings_openai(embedding_input):
    openai.api_key = get_secret(os.environ['OPENAI_API_KEY_SECRET_ID'])
    res = openai.Embedding.create(
        model=embedding_model,
        input=embedding_input
    )
    return res


#
# lambda event handler that starts processing
#
def lambda_handler(event: object, context: object) -> object:
    print(event)
    response = {}
    try:
        embeddings_response = get_embeddings_openai(event["inputText"])
        response["embedding"] = embeddings_response["data"][0]["embedding"]
    except Exception as e:
        raise e

    print(response)
    print("size of response: " + str(len(response["embedding"])))
    return response

