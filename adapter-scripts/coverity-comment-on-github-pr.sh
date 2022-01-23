#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$GITHUB_REPOSITORY" -o -z "$GITHUB_SHA" ]; then
  echo ERROR: Must set GITHUB_REPOSITORY and GITHUB_SHA in the environment | tee -a log
  exit 1
fi

coverityStreamName=`jq '.Resources.Coverity.StreamName' $1 | sed 's/\"//g'`
coverityOutputJson=`jq '.Resources.Coverity.OutputJson' $1 | sed 's/\"//g'`

echo INFO: coverityStreamName=$coverityStreamName | tee -a log
echo INFO: coverityOutputJson=$coverityOutputJson | tee -a log

echo EXEC: python3 ./adapter-scripts/github-coverity-comment-on-pull-request.py \
    --coverity-json $coverityOutputJson \
    --url $coverityUrl \
    --stream $coverityStreamName \
    --sigma-json ./sigma-results.json \
    --debug 9 | tee -a log

#python3 ./adapter-scripts/github-coverity-comment-on-pull-request.py \
#      --coverity-json $coverityOutputJson \
#      --url $coverityUrl \
#      --stream $coverityStreamName \
#      --sigma-json ./sigma-results.json \
#      --debug 9 2>&1 | tee -a log

#contents=$(jq ".Resources.Coverity.Sarif = \"synopsys-coverity-github-sarif.json\"" $1)

#echo INFO: Output of adapter: | tee -a log
#echo $contents | tee -a log

#echo "${contents}" > $1
