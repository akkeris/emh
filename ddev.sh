
LOCALDIR=`pwd`
docker build -t emh .
docker run --rm -v $LOCALDIR:/app  --env-file env.env  -t -i emh  /bin/bash
