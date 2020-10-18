#!/bin/bash


readonly SOURCES=(
  "/root/rsync/src1/"
  "/root/rsync/src2/"
)
TARGET="/root/rsync/backup/"


# clean PATH to prevent accidental usage of commands
unset PATH
# set all needed commands
DATE="/usr/bin/date"
ECHO="/usr/bin/echo"
LN="/usr/bin/ln"
GREP="/usr/bin/grep"
RSYNC="/usr/bin/rsync"

readonly LOG="$0.log"
readonly TIMESTAMP=$($DATE +%Y-%m-%d_%H-%M)

# redirect stdout to ${LOG} in append mode
exec >>"${LOG}"
# redirect stderr to where stdout goes
exec 2>&1

$ECHO "starting backup to TARGET_DIR="${TARGET}" at TIMESTAMP=${TIMESTAMP}"
$ECHO ""

# check if ${TARGET} exists
if ! [ -e "${TARGET}" ]; then
  $ECHO "error: target directory "${TARGET}" not found"
  exit 1
fi
if ! [ -d "${TARGET}" ]; then
  $ECHO "error: "${TARGET}" not a directory"
  exit 1
fi
# check format of ${TARGET}
$ECHO "${TARGET}" | $GREP -qE "/$"
if ! [ $? -eq 0 ]; then
  readonly TARGET_DIR="${TARGET}"/
else
  readonly TARGET_DIR="${TARGET}"
fi


for SOURCE in "${SOURCES[@]}"
do
  # check if ${SOURCE} exists
  if ! [ -e "${SOURCE}" ]; then
    $ECHO "error: directory ${SOURCE} not found"
    $ECHO ""
    continue
  fi
  if ! [ -d "${SOURCE}" ]; then
    $ECHO "error: ${SOURCE} is not a directory"
    $ECHO ""
    continue
  fi
  # check format of ${SOURCE}
  $ECHO "${SOURCE}" | $GREP -qE "/$"
  if ! [ $? -eq 0 ]; then
    SOURCE_DIR="${SOURCE}"/
  else
    SOURCE_DIR="${SOURCE}"
  fi

  $ECHO now processing SOURCE_DIR="${SOURCE_DIR}"

  $ECHO execute: $RSYNC -avR --delete --checksum  "${SOURCE_DIR}" "${TARGET_DIR}${TIMESTAMP}/" --link-dest="${TARGET_DIR}last/"
  $RSYNC -avR --delete --checksum "${SOURCE_DIR}" "${TARGET_DIR}${TIMESTAMP}/" --link-dest="${TARGET_DIR}last/" | $GREP "\S"
  $ECHO ""
done

# create symbolic link to latest backup directory
$ECHO execute: $LN -nsf "${TARGET_DIR}${TIMESTAMP}" "${TARGET_DIR}last"
$LN -nsf "${TARGET_DIR}${TIMESTAMP}" "${TARGET_DIR}last"

$ECHO ""
$ECHO ""

exit 0
