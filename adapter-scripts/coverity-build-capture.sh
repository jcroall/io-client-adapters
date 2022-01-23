#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

coverityLicenseFile=`jq '.Resources.Coverity.LicenseFile' $1 | sed 's/\"//g'`
coverityHome=`jq '.Resources.Coverity.Home' $1 | sed 's/\"//g'`
githubPullRequest=`jq '.Resources.GitHub.PullRequest' $1 | sed 's/\"//g'`
githubChanges=`jq '.Resources.GitHub.Changes' $1 | sed 's/\"//g'`
githubChangesFile=`jq '.Resources.GitHub.ChangesFile' $1 | sed 's/\"//g'`
buildCommand=`jq '.Resources.Coverity.BuildCommand' $1 | sed 's/\"//g'`
echo buildCommand=$buildCommand | tee -a io-log.txt
buildOpts=`jq '.Resources.Coverity.BuildOpts' $1 | sed 's/\"//g'`

echo INFO: coverityLicenseFile=${coverityLicenseFile} | tee -a io-log.txt
echo INFO: githubPullRequest=${githubPullRequest} | tee -a io-log.txt
echo INFO: githubChanges=${githubChanges} | tee -a io-log.txt
echo INFO: githubChangesFile=${githubChangesFile} | tee -a io-log.txt
echo INFO: buildCommand=${buildCommand} | tee -a io-log.txt
echo INFO: buildOpts=${buildOpts} | tee -a io-log.txt

if [ "$buildOpts" = "null" ]; then
  echo INFO: Found buildOpts=$buildOpts, change to empty string | tee -a io-log.txt
  buildOpts=""
fi

COVERITY_IDIR=coverity-idir

# Run Build Capture whether pull request or not

echo EXEC: cov-build --dir $COVERITY_IDIR --append-log $buildOpts $buildCommand | tee -a io-log.txt
cov-build --dir $COVERITY_IDIR --append-log $buildOpts $buildCommand 2>&1 | tee -a io-log.txt

contents=$(jq ".Resources.Coverity.Idir = \"${COVERITY_IDIR}\" | .Resources.Coverity.BuildWasRun = \"true\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt
echo "${contents}" > $1
