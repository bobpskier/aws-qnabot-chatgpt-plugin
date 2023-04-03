# Run "pip install -r -t"  to download python libraries
echo Running pip install or upgrade to download python libraries and set for lambda layer creation
cd ../plugin-layer
if [ -d python ]
then
  pip install -r requirements.txt -t ./python
else
  pip install --upgrade -r requirements.txt -t ./python
fi
cd ../build
