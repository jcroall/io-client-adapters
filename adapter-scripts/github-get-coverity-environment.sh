#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

if [ -z "$COVERITY_URL" -o -z "$COV_USER" -o -z "$COVERITY_PASSPHRASE" -o -z "$COVERITY_HOME"]; then
  echo ERROR: Must set COVERITY_URL, COV_USER, COVERITY_PASSPHRASE and COVERITY_HOME in the environment | tee -a io-log.txt
  exit 1
fi

echo INFO: COVERITY_URL=${COVERITY_URL} | tee -a io-log.txt
echo INFO: COV_USER=${COV_USER} | tee -a io-log.txt
echo INFO: COVERITY_PASSPHRASE=${COVERITY_PASSPHRASE} | tee -a io-log.txt
echo INFO: COVERITY_HOME=${COVERITY_HOME} | tee -a io-log.txt

COVERITY_LICENSEFILE=coverity-license-$$.dat
echo ${COVERITY_LICENSE} > ${COVERITY_LICENSEFILE}
echo Created ${COVERITY_LICENSEFILE} | tee -a io-log.txt
contents=$(jq ".Resources.Coverity.Url = \"${COVERITY_URL}\" | .Resources.Coverity.Username = \"${COV_USER}\" | .Resources.Coverity.Passphrase = \"${COVERITY_PASSPHRASE}\" | .Resources.Coverity.Home = \"${COVERITY_HOME}\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt

echo "${contents}" > $1

