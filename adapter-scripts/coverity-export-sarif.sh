#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

if [ -z "$GITHUB_REPOSITORY" -o -z "$GITHUB_SHA" ]; then
  echo ERROR: Must set GITHUB_REPOSITORY and GITHUB_SHA in the environment | tee -a io-log.txt
  exit 1
fi

coverityHome=`jq '.Resources.Coverity.Home' $1 | sed 's/\"//g'`
coverityOutputJson=`jq '.Resources.Coverity.OutputJson' $1 | sed 's/\"//g'`

echo EXEC: node $coverityHome/SARIF/cov-format-sarif-for-github.js \
    --inputFile $coverityOutputJson \
    --repoName $GITHUB_REPOSITORY \
    --checkoutPath $GITHUB_REPOSITORY `pwd` $GITHUB_SHA \
    --outputFile synopsys-coverity-github-sarif.json | tee -a io-log.txt

node $coverityHome/SARIF/cov-format-sarif-for-github.js \
      --inputFile $coverityOutputJson \
      --repoName $GITHUB_REPOSITORY \
      --checkoutPath $GITHUB_REPOSITORY `pwd` $GITHUB_SHA \
      --outputFile synopsys-coverity-github-sarif.json 2>&1 | tee -a io-log.txt


contents=$(jq ".Resources.Coverity.Sarif = \"synopsys-coverity-github-sarif.json\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt

echo "${contents}" > $1
