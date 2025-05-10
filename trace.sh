#!/bin/bash

set -e

trap error_handler ERR

rm -rf output && mkdir output

lttng create session1 --output=./output

lttng enable-channel --userspace --num-subbuf=4 --subbuf-size=64M channel0

lttng enable-event --channel channel0 --userspace --all
lttng add-context --channel channel0 --userspace --type="procname"
lttng add-context --channel channel0 --userspace --type="vtid"
lttng add-context --channel channel0 --userspace --type="vpid"
lttng add-context --channel channel0 --userspace --type="perf:thread:cpu-cycles"
lttng add-context --channel channel0 --userspace --type="perf:thread:instructions"
lttng add-context --channel channel0 --userspace --type="perf:thread:cache-misses"

lttng start

sleep 0.25 

lttng destroy
