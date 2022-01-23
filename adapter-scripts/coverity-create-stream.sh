#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

scmRepoName=`jq '.Scm.Repository.Name' $1 | sed 's/\"//g' | tr '/' ' ' | awk '{ print $2 }'`
projectBranchName=`jq '.Project.Branch.Name' $1 | sed 's/\"//g'`

COVERITY_STREAM_NAME="$scmRepoName"-"$projectBranchName"
echo INFO: Coverity stream name: ${COVERITY_STREAM_NAME} | tee -a io-log.txt

echo Ensure that stream "$COVERITY_STREAM_NAME" exists | tee -a io-log.txt
echo EXEC: cov-manage-im --url $COVERITY_URL --on-new-cert trust --mode projects --add --set name:"$COVERITY_STREAM_NAME" | tee -a io-log.txt
cov-manage-im --url $COVERITY_URL --on-new-cert trust --mode projects --add --set name:"$COVERITY_STREAM_NAME" | tee -a io-log.txt || true
echo EXEC: cov-manage-im --url $COVERITY_URL --on-new-cert trust --mode streams --add -set name:"$COVERITY_STREAM_NAME" | tee -a io-log.txt
cov-manage-im --url $COVERITY_URL --on-new-cert trust --mode streams --add -set name:"$COVERITY_STREAM_NAME" | tee -a io-log.txt || true
echo EXEC: cov-manage-im --url $COVERITY_URL --on-new-cert trust --mode projects --update --name "$COVERITY_STREAM_NAME" --insert  stream:"$COVERITY_STREAM_NAME" | tee -a io-log.txt
cov-manage-im --url $COVERITY_URL --on-new-cert trust --mode projects --update --name "$COVERITY_STREAM_NAME" --insert  stream:"$COVERITY_STREAM_NAME" | tee -a io-log.txt || true

contents=$(jq ".Resources.Coverity.StreamName = \"${COVERITY_STREAM_NAME}\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt

echo "${contents}" > $1
