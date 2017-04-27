#!/bin/bash

set -e
set -o pipefail
. path.sh

gunzip -c data/lang/g.txt.gz | \
   utils/remove_oovs.pl data/lang/oov.txt | \
   utils/phi2disambig.pl | utils/s2eps.pl | \
   fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt | \
   fstrmepslocal | fstarcsort --sort_type=ilabel > data/lang/G.fst
echo  "$0: Checking how stochastic G is (the first of these numbers should be small):"
fstisstochastic data/lang/G.fst || true
utils/validate_lang.pl --skip-determinization-check data/lang
