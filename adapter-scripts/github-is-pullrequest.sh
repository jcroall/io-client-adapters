#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

if [ -z "$GITHUB_REF" ]; then
  echo ERROR: GITHUB_REF not found in environment
  exit 1
fi

echo $GITHUB_REF | egrep refs/pull
if [ $? -ne 0 ]; then
  echo INFO: GitHub workflow not running for pull request | tee -a io-log.txt
  PULL_NUMBER=false
else
  echo INFO: GitHub workflow running for pull request | tee -a io-log.txt
  PULL_NUMBER=`echo $GITHUB_REF | tr '/' ' ' | awk '{ print $3 }'`
fi


contents=$(jq ".Resources.GitHub.PullRequest = \"${PULL_NUMBER}\"" $1)

echo INFO: Output of adapter $0: | tee -a io-log.txt
echo $contents | tee -a io-log.txt

echo "${contents}" > $1
