# Run "pip install -r -t"  to download python libraries
echo Running pip install or upgrade to download python libraries and set for lambda layer creation
cd ../plugin-layer
if [ -d "python" ]
then
  pip install --platform manylinux2014_x86_64 --only-binary=:all: --upgrade -r requirements.txt -t ./python
else
  pip install --platform manylinux2014_x86_64 --only-binary=:all: -r requirements.txt -t ./python
fi
cd ../build
