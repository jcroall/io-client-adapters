#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$GITHUB_REPOSITORY" -o -z "$GITHUB_SHA" ]; then
  echo ERROR: Must set GITHUB_REPOSITORY and GITHUB_SHA in the environment | tee -a log
  exit 1
fi

coverityHome=`jq '.Resources.Coverity.Home' $1 | sed 's/\"//g'`
coverityOutputJson=`jq '.Resources.Coverity.OutputJson' $1 | sed 's/\"//g'`

echo EXEC: node $coverityHome/SARIF/cov-format-sarif-for-github.js \
    --inputFile $coverityOutputJson \
    --repoName $GITHUB_REPOSITORY \
    --checkoutPath $GITHUB_REPOSITORY `pwd` $GITHUB_SHA \
    --outputFile synopsys-coverity-github-sarif.json | tee -a log

node $coverityHome/SARIF/cov-format-sarif-for-github.js \
      --inputFile $coverityOutputJson \
      --repoName $GITHUB_REPOSITORY \
      --checkoutPath $GITHUB_REPOSITORY `pwd` $GITHUB_SHA \
      --outputFile synopsys-coverity-github-sarif.json 2>&1 | tee -a log


contents=$(jq ".Resources.Coverity.Sarif = \"synopsys-coverity-github-sarif.json\"" $1)

echo INFO: Output of adapter: | tee -a log
echo $contents | tee -a log

echo "${contents}" > $1
