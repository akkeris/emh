#!/bin/bash

echo $APP_URL
export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

mkdir ./test-results
rm -f ./test-results/*

function shutdown {
  kill -s SIGTERM $NODE_PID
  wait $NODE_PID
}

if [ ! -z "$SE_OPTS" ]; then
  echo "appending selenium options: ${SE_OPTS}"
fi


rm -f /tmp/.X*lock

xvfb-run  --server-args="-screen 0 $GEOMETRY -ac +extension RANDR" \
  java ${JAVA_OPTS} -jar /opt/selenium/selenium-server-standalone.jar \
  ${SE_OPTS} &
NODE_PID=$!

trap shutdown  SIGTERM SIGINT
if [ -z "$APP_PATH" ]; then
echo You need to pass in APP_PATH
exit 1
else
    bundle exec parallel_rspec spec/features/${APP_PATH}
    export RESULT=$? 
fi

if [ ! -z "${TAAS_RUNID}" ]; then
  cd ./test-results
  export AWS_REGION=${TAAS_ARTIFACT_REGION}
  export AWS_ACCESS_KEY_ID=${TAAS_AWS_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${TAAS_AWS_SECRET_ACCESS_KEY}
  aws s3 sync . s3://$TAAS_ARTIFACT_BUCKET/$TAAS_RUNID
fi

exit $RESULT
wait $NODE_PID
exit $RESULT

