#!/bin/bash

# Compute scores from connLM. Modified from utils/connlm_compute_scores.sh

. ./path.sh || exit 1;
. utils/parse_options.sh

connlm_root=$KALDI_ROOT/tools/connLM

[ ! -d $connlm_root ] && echo connLM not installed && exit 1;

. $connlm_root/egs/steps/path.sh

if [ $# != 4 ]; then
  echo "Usage: connlm_compute_scores.sh <connlm-dir> <temp-dir> <input-text> <output-scores>"
  exit 1;
fi

dir=$1
tempdir=$2
text_in=$3
scores_out=$4

for x in final.clm; do
  if [ ! -f $dir/$x ]; then
    echo "connlm_compute_scores.sh: expected file $dir/$x to exist."
    exit 1;
  fi
done

mkdir -p $tempdir
cat $text_in | awk '{for (x=2;x<=NF;x++) {printf("%s ", $x)} printf("\n");}' >$tempdir/text
cat $text_in | awk '{print $1}' > $tempdir/ids # e.g. utterance ids.

connlm-eval --print-sent-prob=true --reader^drop-empty-line=false \
            --log-file=$tempdir/eval.log \
            $dir/final.clm $tempdir/text $tempdir/loglikes

awk '{print -$1}' $tempdir/loglikes >$tempdir/scores

# scores out, with utterance-ids.
paste $tempdir/ids $tempdir/scores  > $scores_out
