
LOCALDIR=`pwd`
docker build -t emh:latest .
docker run --rm -v $LOCALDIR:/app  --env-file env.env emh:latest
