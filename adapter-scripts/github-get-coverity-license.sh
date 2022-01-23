#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a io-log.txt
echo INFO: IO State: | tee -a io-log.txt
cat $1 | tee -a io-log.txt
echo ---------------------------- | tee -a io-log.txt

if [ -z "$COVERITY_LICENSE" ]; then
  echo ERROR: Must set COVERITY_LICENSE in the environment | tee -a io-log.txt
  exit 1
fi

COVERITY_LICENSEFILE=coverity-license-$$.dat
echo ${COVERITY_LICENSE} > ${COVERITY_LICENSEFILE}

echo INFO: Created ${COVERITY_LICENSEFILE} | tee -a io-log.txt

contents=$(jq ".Resources.Coverity.LicenseFile = \"${COVERITY_LICENSEFILE}\"" $1)

echo INFO: Output of adapter: | tee -a io-log.txt
echo $contents | tee -a io-log.txt

echo "${contents}" > $1
