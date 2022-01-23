#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

coverityLicenseFile=`jq '.Resources.Coverity.LicenseFile' $1 | sed 's/\"//g'`
coverityStreamName=`jq '.Resources.Coverity.StreamName' $1 | sed 's/\"//g'`
coverityUrl=`jq '.Resources.Coverity.Url' $1 | sed 's/\"//g'`
coverityUsername=`jq '.Resources.Coverity.Username' $1 | sed 's/\"//g'`
coverityPassphrase=`jq '.Resources.Coverity.Passphrase' $1 | sed 's/\"//g'`
coverityHome=`jq '.Resources.Coverity.Home' $1 | sed 's/\"//g'`
githubPullRequest=`jq '.Resources.GitHub.PullRequest' $1 | sed 's/\"//g'`
githubChanges=`jq '.Resources.GitHub.Changes' $1 | sed 's/\"//g'`
githubChangesFile=`jq '.Resources.GitHub.ChangesFile' $1 | sed 's/\"//g'`
projectDir=`jq '.Resources.Coverity.ProjectDir' $1 | sed 's/\"//g'`
analysisOpts=`jq '.Resources.Coverity.AnalysisOpts' $1 | sed 's/\"//g'`

echo INFO: coverityLicenseFile=${coverityLicenseFile} | tee -a log
echo INFO: coverityStreamName=${coverityStreamName} | tee -a log
echo INFO: coverityUrl=${coverityUrl} | tee -a log
echo INFO: coverityUsername=${coverityUsername} | tee -a log
echo INFO: coverityPassphrase=${coverityPassphrase} | tee -a log
echo INFO: githubPullRequest=${githubPullRequest} | tee -a log
echo INFO: projectDir=${projectDir} | tee -a log
echo INFO: analysisOpts=${projectDir} | tee -a log

if [ "$projectDir" = "null" -o -z "$projectDir" ]; then
  echo INFO: Found projectDir=$projectDir, change to .
  projectDir="."
fi

if [ "$analysisOpts" = "null" ]; then
  echo INFO: Found analysisOpts=$analysisOpts, change to empty string | tee -a log
  analysisOpts=""
fi

COVERITY_IDIR=idir-$$

if [ "$githubPullRequest" = "null" ]; then
  echo INFO: Not running on a pull request - Running FULL analysis | tee -a log

  echo EXEC: cov-capture --dir $COVERITY_IDIR --project-dir $projectDir | tee -a log
  cov-capture --dir $COVERITY_IDIR --project-dir $projectDir 2>&1 | tee -a log

  echo EXEC: cov-analyze --dir $COVERITY_IDIR --strip-path `pwd` --security-file $coverityLicenseFile $analysisOpts | tee -a log
  cov-analyze --dir $COVERITY_IDIR --strip-path `pwd` --security-file $coverityLicenseFile $analysisOpts 2>&1 | tee -a log

  echo EXEC: cov-commit-defects --dir $COVERITY_IDIR --security-file $coverityLicenseFile --ticker-mode none --url $coverityUrl --on-new-cert trust --stream $coverityStreamName --scm git | tee -a log
  cov-commit-defects --dir $COVERITY_IDIR --security-file $coverityLicenseFile --ticker-mode none --url $coverityUrl --on-new-cert trust --stream $coverityStreamName --scm git 2>&1 | tee -a log

  echo EXEC: cov-format-errors --dir $COVERITY_IDIR --security-file $coverityLicenseFile --json-output-v7 coverity-output.json | tee -a log
  cov-format-errors --dir $COVERITY_IDIR --security-file $coverityLicenseFile --json-output-v7 coverity-output.json 2>&1 | tee -a log

  echo EXEC: $coverityHome/sigma/bin/sigma analyze | tee -a log
  $coverityHome/sigma/bin/sigma analyze 2>&1 | tee -a log
else
  echo INFO: Running on a pull request - Running INCREMENTAL analysis | tee -a log

  echo EXEC: cov-capture --dir $COVERITY_IDIR --source-list $githubChangesFile | tee -a log
  cov-capture --dir $COVERITY_IDIR --source-list $githubChangesFile 2>&1 | tee -a log

  echo EXEC: cov-run-desktop --dir $COVERITY_IDIR --strip-path `pwd` --url $coverityUrl --stream $coverityStreamName --present-in-reference false \
    --ignore-uncapturable-inputs true \
    --security-file $coverityLicenseFile \
    --json-output-v7 coverity-output.json \
    @@$githubChangesFile | tee -a log
  cov-run-desktop --dir $COVERITY_IDIR --strip-path `pwd` --url $coverityUrl --stream $coverityStreamName --present-in-reference false \
            --ignore-uncapturable-inputs true \
            --security-file $coverityLicenseFile \
            --json-output-v7 coverity-output.json \
            @@$githubChangesFile 2>&1 | tee -a log

  echo EXEC: $coverityHome/sigma/bin/sigma analyze | tee -a log
  $coverityHome/sigma/bin/sigma analyze 2>&1 | tee -a log
fi

contents=$(jq ".Resources.Coverity.Idir = \"${COVERITY_IDIR}\" | .Resources.Coverity.OutputJson = \"coverity-output.json\"" $1)

echo INFO: Output of adapter: | tee -a log
echo $contents | tee -a log
echo "${contents}" > $1
