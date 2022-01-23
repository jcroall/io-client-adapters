#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$GITHUB_API_URL" -o -z "$GITHUB_TOKEN" -o -z "$GITHUB_REPOSITORY" -o -z "$GITHUB_SHA" -o -z "$GITHUB_REF"]; then
  echo ERROR: Must set GITHUB_API_URL, GITHUB_TOKEN, GITHUB_REPOSITORY, GITHUB_SHA, and GITHUB_REF in the environment | tee -a log
  exit 1
fi

githubChangesFile="github-changes-$$.txt"

echo EXEC: python3 ~/PycharmProjects/synopsys-github-tools/github-get-changed-files.py --output ${githubChangesFile} --debug 9 | tee -a log
python3 ~/PycharmProjects/synopsys-github-tools/github-get-changed-files.py --output ${githubChangesFile} --debug 9 2>&1 | tee -a log

githubChanges=""
for file in `cat ${githubChangesFile}`; do
  githubChanges="${githubChanges} "${file}""
done
echo INFO: githubChanges=${githubChanges} | tee -a log

contents=$(jq ".Resources.GitHub.Changes = \"${githubChanges}\" | .Resources.GitHub.ChangesFile = \"${githubChangesFile}\"" $1)

echo INFO: Output of adapter: | tee -a log
echo $contents | tee -a log

echo "${contents}" > $1
