#!/bin/bash

# Begin configuration section.
num_threads=8 # set this value to the number of physical cores on your CPU
stage=0
# End configuration section.

echo "$0 $@"  # Print the command line for logging

. path.sh
. utils/parse_options.sh

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <lm-dir> <model-dir>"
  echo "e.g.: $0 data/lang_connlm exp/chain/tdnn1b_sp_bi"
  echo "Main options:"
  echo "  --stage <int>"
  exit 1
fi

s5_dir=`pwd`
connlm_dir=`readlink -f $1`
model_dir=`readlink -f $2`

if [ $stage -le 1 ]; then
  echo "$0: Performing connLM rescoring on decoding results"
  for dset in dev test; do
    sourcedir=${model_dir}/decode_${dset}
    if [ ! -d "$sourcedir" ]; then
        echo "$0: WARNING cannot find source dir '$sourcedir' to rescore"
        continue
    fi
    resultsdir=${sourcedir}_connlm
    rm -rf ${resultsdir}_L0.5
    steps/connlmrescore.sh --skip_scoring false --N 100 0.5 data/lang $connlm_dir data/${dset}_hires $sourcedir ${resultsdir}_L0.5
    for coef in 0.25 0.75 1.0; do
      rm -rf ${resultsdir}_L${coef}
      cp -r ${resultsdir}_L0.5 ${resultsdir}_L${coef}
      steps/connlmrescore.sh --skip_scoring false --N 100 --stage 7 $coef data/lang $connlm_dir data/${dset}_hires $sourcedir ${resultsdir}_L${coef}
    done
  done
fi
