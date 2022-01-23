#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

if [ -z "$GITHUB_API_URL" -o -z "$GITHUB_TOKEN" -o -z "$GITHUB_REPOSITORY" -o -z "$GITHUB_SHA" -o -z "$GITHUB_REF"]; then
  echo ERROR: Must set GITHUB_API_URL, GITHUB_TOKEN, GITHUB_REPOSITORY, GITHUB_SHA, and GITHUB_REF in the environment | tee -a io-log.txt
  exit 1
fi

githubChangesFile="github-changes-$$.txt"

DIRECTORY=`dirname $0`
echo EXEC: python3 $DIRECTORY/github-get-changed-files.py --output ${githubChangesFile} --debug 9 | tee -a io-log.txt
python3 $DIRECTORY/github-get-changed-files.py --output ${githubChangesFile} --debug 9 2>&1 | tee -a io-log.txt

githubChanges=""
for file in `cat ${githubChangesFile}`; do
  githubChanges="${githubChanges} "${file}""
done
echo INFO: githubChanges=${githubChanges} | tee -a io-log.txt

contents=$(jq ".Resources.GitHub.Changes = \"${githubChanges}\" | .Resources.GitHub.ChangesFile = \"${githubChangesFile}\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt

echo "${contents}" > $1
