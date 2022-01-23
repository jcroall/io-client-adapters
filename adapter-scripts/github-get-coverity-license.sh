#!/bin/bash
echo == IO Adapter: $0 ========== | tee -a log
echo INFO: IO State: | tee -a log
cat $1 | tee -a log
echo ---------------------------- | tee -a log

if [ -z "$COVERITY_LICENSE" ]; then
  echo ERROR: Must set COVERITY_LICENSE in the environment | tee -a log
  exit 1
fi

COVERITY_LICENSEFILE=coverity-license-$$.dat
echo ${COVERITY_LICENSE} > ${COVERITY_LICENSEFILE}

echo INFO: Created ${COVERITY_LICENSEFILE} | tee -a log

contents=$(jq ".Resources.Coverity.LicenseFile = \"${COVERITY_LICENSEFILE}\"" $1)

echo INFO: Output of adapter: | tee -a log
echo $contents | tee -a log

echo "${contents}" > $1
