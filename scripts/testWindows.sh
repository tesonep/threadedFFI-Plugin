#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

#Run Tests in windows
LOCAL_DIR=`pwd`

if [ $1 -eq "32" ]; then
	ARCH=32
	PHARO_URL=get.pharo.org/70+vmLatest
else
	ARCH=64
	PHARO_URL=get.pharo.org/64/70+vmLatest
fi


rm -rf "${__root}/results/tests/windows$ARCH"
mkdir -p "${__root}/results/tests/windows$ARCH"
cd "${__root}/results/tests/windows$ARCH"

wget -O - $PHARO_URL | bash

cp "${__root}/results/PharoThreadedFFI-windows$ARCH.zip" "pharo-vm"
unzip pharo-vm/PharoThreadedFFI-windows$ARCH.zip -d pharo-vm

__winroot=`cygpath -w ${__root}`

./pharo Pharo.image st --save --quit ${__winroot}/scripts/updateIceberg.st

./pharo Pharo.image eval "

[Metacello new
        baseline: 'ThreadedFFI';
        repository: 'tonel://${__winroot}/src';
        ignoreImage;
        onConflictUseIncoming;
        onUpgradeUseLoaded: false;
        onDowngradeUseIncoming;
        load] on: MetacelloIgnorePackageLoaded do: [ :e | e resume: true ].
		
Smalltalk saveAs:'testFFI'.
		"

cp "${__root}/results/testLibrary/$ARCH/testLibrary.dll" .

./pharo testFFI.image test --fail-on-failure "ThreadedFFI-Tests" "ThreadedFFI-UFFI-Tests"

cd $LOCAL_DIR
