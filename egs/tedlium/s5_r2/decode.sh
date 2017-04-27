#!/bin/bash

set -e

. path.sh

local/chain/run_tdnn.sh --stage 19 --nnet3-affix "" --train-set train --tdnn-affix 1b --decode-nj 4
