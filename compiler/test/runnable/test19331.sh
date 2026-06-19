#!/usr/bin/env bash

if [ "$OS" != 'osx' ] || [ "$MODEL" != '64' ]; then
    echo Success >${output_file}
    exit 0
fi

set -e

src=runnable/extra-files
dir=${RESULTS_DIR}/runnable
output_file=${dir}/test19331.sh.out

$DMD -I${src} -of${OUTPUT_BASE}${LIBEXT} -lib ${src}/test19331a.d

echo Success >${output_file}
