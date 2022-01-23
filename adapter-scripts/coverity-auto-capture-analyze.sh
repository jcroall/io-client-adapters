#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

coverityLicenseFile=`jq '.Resources.Coverity.LicenseFile' $1 | sed 's/\"//g'`
coverityStreamName=`jq '.Resources.Coverity.StreamName' $1 | sed 's/\"//g'`
coverityUrl=`jq '.Resources.Coverity.Url' $1 | sed 's/\"//g'`
coverityUsername=`jq '.Resources.Coverity.Username' $1 | sed 's/\"//g'`
coverityPassphrase=`jq '.Resources.Coverity.Passphrase' $1 | sed 's/\"//g'`
coverityHome=`jq '.Resources.Coverity.Home' $1 | sed 's/\"//g'`
#coverityIdir=`jq '.Resources.Coverity.Idir' $1 | sed 's/\"//g'`
coverityBuildWasRun=`jq '.Resources.Coverity.BuildWasRun' $1 | sed 's/\"//g'`
githubPullRequest=`jq '.Resources.GitHub.PullRequest' $1 | sed 's/\"//g'`
githubChanges=`jq '.Resources.GitHub.Changes' $1 | sed 's/\"//g'`
githubChangesFile=`jq '.Resources.GitHub.ChangesFile' $1 | sed 's/\"//g'`
projectDir=`jq '.Resources.Coverity.ProjectDir' $1 | sed 's/\"//g'`
analysisOpts=`jq '.Resources.Coverity.AnalysisOpts' $1 | sed 's/\"//g'`

echo INFO: coverityLicenseFile=${coverityLicenseFile} | tee -a io-log.txt
echo INFO: coverityStreamName=${coverityStreamName} | tee -a io-log.txt
echo INFO: coverityUrl=${coverityUrl} | tee -a io-log.txt
echo INFO: coverityUsername=${coverityUsername} | tee -a io-log.txt
echo INFO: coverityPassphrase=${coverityPassphrase} | tee -a io-log.txt
echo INFO: coverityIdir=${coverityIdir} | tee -a io-log.txt
echo INFO: coverityBuildWasRun=${coverityBuildWasRun} | tee -a io-log.txt
echo INFO: githubPullRequest=${githubPullRequest} | tee -a io-log.txt
echo INFO: projectDir=${projectDir} | tee -a io-log.txt
echo INFO: analysisOpts=${projectDir} | tee -a io-log.txt

if [ "$projectDir" = "null" -o -z "$projectDir" ]; then
  echo INFO: Found projectDir=$projectDir, change to .
  projectDir="."
fi

if [ "$analysisOpts" = "null" ]; then
  echo INFO: Found analysisOpts=$analysisOpts, change to empty string | tee -a io-log.txt
  analysisOpts=""
fi

#if [ "$coverityIdir" = "null" ]; then
#  echo INFO: Found coverityIdira=null, change to default value 'coverity-idir' | tee -a io-log.txt
#  COVERITY_IDIR=coverity-idir
#else:
#  COVERITY_IDIR=$coverityIdir
#fi

COVERITY_IDIR=coverity-idir

if [ "$githubPullRequest" = "null" ]; then
  echo INFO: Not running on a pull request - Running FULL analysis | tee -a io-log.txt

  if [ "$coverityBuildWasRun" = "null" ]; then
    echo INFO: Running with auto capture, no build command previously run | tee -a io-log.txt
    echo EXEC: cov-capture --dir $COVERITY_IDIR --project-dir $projectDir | tee -a io-log.txt
    cov-capture --dir $COVERITY_IDIR --project-dir $projectDir 2>&1 | tee -a io-log.txt
  else
    echo echo INFO: Build capture already executed, skipping ahead to analysis | tee -a io-log.txt
  fi

  echo EXEC: cov-analyze --dir $COVERITY_IDIR --strip-path `pwd` --security-file $coverityLicenseFile $analysisOpts | tee -a io-log.txt
  cov-analyze --dir $COVERITY_IDIR --strip-path `pwd` --security-file $coverityLicenseFile $analysisOpts 2>&1 | tee -a io-log.txt

  echo EXEC: cov-commit-defects --dir $COVERITY_IDIR --security-file $coverityLicenseFile --ticker-mode none --url $coverityUrl --on-new-cert trust --stream $coverityStreamName --scm git | tee -a io-log.txt
  cov-commit-defects --dir $COVERITY_IDIR --security-file $coverityLicenseFile --ticker-mode none --url $coverityUrl --on-new-cert trust --stream $coverityStreamName --scm git 2>&1 | tee -a io-log.txt

  echo EXEC: cov-format-errors --dir $COVERITY_IDIR --security-file $coverityLicenseFile --json-output-v7 coverity-output.json | tee -a io-log.txt
  cov-format-errors --dir $COVERITY_IDIR --security-file $coverityLicenseFile --json-output-v7 coverity-output.json 2>&1 | tee -a io-log.txt

  echo EXEC: $coverityHome/sigma/bin/sigma analyze | tee -a io-log.txt
  $coverityHome/sigma/bin/sigma analyze 2>&1 | tee -a io-log.txt
else
  echo INFO: Running on a pull request - Running INCREMENTAL analysis | tee -a io-log.txt

  if [ "$coverityBuildWasRun" = "null" ]; then
    echo INFO: Running with auto capture, no build command previously run | tee -a io-log.txt
    echo EXEC: cov-capture --dir $COVERITY_IDIR --source-list $githubChangesFile | tee -a io-log.txt
    cov-capture --dir $COVERITY_IDIR --source-list $githubChangesFile 2>&1 | tee -a io-log.txt
  else
    echo echo INFO: Build capture already executed, skipping ahead to analysis | tee -a io-log.txt
  fi

  echo EXEC: cov-run-desktop --dir $COVERITY_IDIR --strip-path `pwd` --url $coverityUrl --stream $coverityStreamName --present-in-reference false \
    --ignore-uncapturable-inputs true \
    --security-file $coverityLicenseFile \
    --json-output-v7 coverity-output.json \
    @@$githubChangesFile | tee -a io-log.txt
  cov-run-desktop --dir $COVERITY_IDIR --strip-path `pwd` --url $coverityUrl --stream $coverityStreamName --present-in-reference false \
            --ignore-uncapturable-inputs true \
            --security-file $coverityLicenseFile \
            --json-output-v7 coverity-output.json \
            @@$githubChangesFile 2>&1 | tee -a io-log.txt

  echo EXEC: $coverityHome/sigma/bin/sigma analyze | tee -a io-log.txt
  $coverityHome/sigma/bin/sigma analyze 2>&1 | tee -a io-log.txt
fi

contents=$(jq ".Resources.Coverity.Idir = \"${COVERITY_IDIR}\" | .Resources.Coverity.OutputJson = \"coverity-output.json\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt
echo "${contents}" > $1
