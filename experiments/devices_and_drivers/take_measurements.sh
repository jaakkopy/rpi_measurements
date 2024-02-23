#!/bin/bash

bluetooth_addr=$1
outdir=$2
outfileprefix=$3

for i in {1..50}
do
    python ../../measurement.py ${bluetooth_addr} 30 1 > ./${outdir}/${outfileprefix}${i}.csv
    sleep 5
done