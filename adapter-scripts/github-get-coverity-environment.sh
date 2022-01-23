#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$COVERITY_URL" -o -z "$COV_USER" -o -z "$COVERITY_PASSPHRASE" -o -z "$COVERITY_HOME"]; then
  echo ERROR: Must set COVERITY_URL, COV_USER, COVERITY_PASSPHRASE and COVERITY_HOME in the environment | tee -a log
  exit 1
fi

echo INFO: COVERITY_URL=${COVERITY_URL} | tee -a log
echo INFO: COV_USER=${COV_USER} | tee -a log
echo INFO: COVERITY_PASSPHRASE=${COVERITY_PASSPHRASE} | tee -a log
echo INFO: COVERITY_HOME=${COVERITY_HOME} | tee -a log

COVERITY_LICENSEFILE=coverity-license-$$.dat
echo ${COVERITY_LICENSE} > ${COVERITY_LICENSEFILE}
echo Created ${COVERITY_LICENSEFILE} | tee -a log
contents=$(jq ".Resources.Coverity.Url = \"${COVERITY_URL}\" | .Resources.Coverity.Username = \"${COV_USER}\" | .Resources.Coverity.Passphrase = \"${COVERITY_PASSPHRASE}\" | .Resources.Coverity.Home = \"${COVERITY_HOME}\"" $1)

echo INFO: Output of adapter: | tee -a log
echo $contents | tee -a log

echo "${contents}" > $1

