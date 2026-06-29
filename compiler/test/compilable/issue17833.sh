#!/usr/bin/env bash

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

$DMD -I../../druntime/src -I${EXTRA_FILES}/${TEST_NAME} -c -deps ${EXTRA_FILES}/${TEST_NAME}/fun3.d ${EXTRA_FILES}/${TEST_NAME}/fun2.d >"${tmpdir}/deps1.txt"
$DMD -I../../druntime/src -I${EXTRA_FILES}/${TEST_NAME} -c -deps ${EXTRA_FILES}/${TEST_NAME}/fun2.d ${EXTRA_FILES}/${TEST_NAME}/fun3.d >"${tmpdir}/deps2.txt"

deps1=$(wc -l < "${tmpdir}/deps1.txt")
deps2=$(wc -l < "${tmpdir}/deps2.txt")

if [ "${deps1}" != "${deps2}" ]; then
    echo "expected identical -deps output line counts, got ${deps1} and ${deps2}"
    exit 1
fi
