#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$GITHUB_REF" ]; then
  echo ERROR: GITHUB_REF not found in environment
  exit 1
fi

echo $GITHUB_REF | egrep refs/pull
if [ $? -ne 0 ]; then
  echo INFO: GitHub workflow not running for pull request | tee -a log
  exit 0
else
  echo INFO: GitHub workflow running for pull request | tee -a log
fi

PULL_NUMBER=`echo $GITHUB_REF | tr '/' ' ' | awk '{ print $3 }'`

contents=$(jq ".Resources.GitHub.PullRequest = \"${PULL_NUMBER}\"" $1)

echo INFO: Output of adapter $0: | tee -a log
echo $contents | tee -a log

echo "${contents}" > $1
