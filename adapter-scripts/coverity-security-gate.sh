#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$GITHUB_REPOSITORY" -o -z "$GITHUB_SHA" ]; then
  echo ERROR: Must set GITHUB_REPOSITORY and GITHUB_SHA in the environment | tee -a log
  exit 1
fi

coverityUrl=`jq '.Resources.Coverity.Url' $1 | sed 's/\"//g'`
coverityStreamName=`jq '.Resources.Coverity.StreamName' $1 | sed 's/\"//g'`
coverityUsername=`jq '.Resources.Coverity.Username' $1 | sed 's/\"//g'`
coverityPassphrase=`jq '.Resources.Coverity.Passphrase' $1 | sed 's/\"//g'`
coveritySecurityGateView=`jq '.Resources.Coverity.SecurityGateView' $1 | sed 's/\"//g'`

COVERITY_VIEW_ESCAPED=`jq -rn --arg x "$coveritySecurityGateView" '$x|@uri'`

# TODO This should proabbly be the project name, not stream name
echo EXEC: curl -kfLsS --user $coverityUsername:$coverityPassphrase $coverityUrl/api/viewContents/issues/v1/$COVERITY_VIEW_ESCAPED?projectId=$coverityStreamName | tee -a log
curl -kfLsS --user $coverityUsername:$coverityPassphrase $coverityUrl/api/viewContents/issues/v1/$COVERITY_VIEW_ESCAPED?projectId=$coverityStreamName > security-gate-results.json
STATUS=pass
if [ $(cat security-gate-results.json | jq .viewContentsV1.totalRows) -ne 0 ]; then cat security-gate-results.json | jq .viewContentsV1.rows; STATUS=fail; fi

contents=$(jq ".Resources.Coverity.PassOrFail = \"$STATUS\"" $1)

echo INFO: Output of adapter: | tee -a log
echo $contents | tee -a log

echo "${contents}" > $1
