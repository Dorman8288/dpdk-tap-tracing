# DPDK Tracing with LTTng

This project provides a step-by-step guide to building and tracing DPDK applications using LTTng. The focus is on enabling function-level tracing to analyze DPDK behavior during runtime.

## 📦 Prerequisites

Ensure the following packages are installed:

```bash
sudo apt update
sudo apt install -y meson ninja-build build-essential libnuma-dev libpcap-dev libelf-dev libjansson-dev libtool libtool-bin pkg-config
```

Install LTTng and related tools:

```bash
sudo apt install -y lttng-tools lttng-modules-dkms babeltrace
```

## 🔧 Build DPDK with Function Instrumentation

Clone and build DPDK with `-finstrument-functions` flag to enable function tracing:

```bash
git clone https://github.com/DPDK/dpdk.git
cd dpdk
meson setup --buildtype=debug -Dexamples=all debugbuildtrace
cd debugbuildtrace
meson configure -Dc_args="-finstrument-functions" -Dcpp_args="-finstrument-functions"
ninja -C debugbuildtrace
```

## 🧠 Mount HugePages

DPDK requires hugepages for memory allocation. Run:

```bash
sudo mkdir -p /mnt/huge
sudo mount -t hugetlbfs nodev /mnt/huge
```

You can also enable hugepages at boot or dynamically allocate them:

```bash
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages
```

## 🚀 Run DPDK Application
```bash
sudo LD_PRELOAD=/usr/lib/x86_64-linux-gnu/liblttng-ust-cyg-profile.so ./dpdk-testpmd -l 0-1 --proc-type=primary --file-prefix=pmd1 --vdev=net_memif,role=server -- -i
sudo LD_PRELOAD=/usr/lib/x86_64-linux-gnu/liblttng-ust-cyg-profile.so ./dpdk-testpmd -l 2-3 --proc-type=primary --file-prefix=pmd2 --vdev=net_memif -- -i
```

## 🔍 Enable LTTng Tracing

Create a new LTTng tracing session and enable function instrumentation with this script file:

```bash
#!/bin/bash

set -e

error_handler()
{
        echo -e "An error occured in the script\n"
        lttng destroy
        exit 1
}

if [ "$(id -u)" -ne 0 ];
then
        echo -e "permission denied.\nneeds root previlliged" >&2
        exit 1
fi

trap error_handler ERR

rm -rf output && mkdir output

lttng create session1 --output=./output

lttng enable-channel --userspace --num-subbuf=4 --subbuf-size=64M channel0

lttng enable-event --channel channel0 --userspace --all

for context in 'procname' 'vtid' 'vpid' 'perf:thread:cpu-cycles' 'perf:thread:instructions' 'perf:thread:cache-misses'; 
# for context in 'procname' 'vtid' 'vpid' 'perf:thread:instructions'; 
do
        lttng add-context --channel channel0 --userspace --type="$context"
done

lttng start

sleep 0.25

lttng destroy

```

## 🚀 Run DPDK Application
```bash
lttng stop
lttng destroy
```

## 📊 View Traces

Use `tracecompass` to read and analyze the trace logs:

```bash
sudo .location_of_tracecompass/tracecompass
```

## 📂 Project Structure

```
.
├── dpdk/                    # Cloned DPDK source
│   └── debugbuildtrace/    # Build directory with instrumented binaries
├── README.md                # This file
```

## 🧪 Optional: Save to Script

You can automate the steps using a Bash script:

```bash
#!/bin/bash

# Build DPDK
git clone https://github.com/DPDK/dpdk.git
cd dpdk
meson setup --buildtype=debug -Dexamples=all debugbuildtrace
cd debugbuildtrace
meson configure -Dc_args="-finstrument-functions"
ninja

# Mount hugepages
sudo mkdir -p /mnt/huge
sudo mount -t hugetlbfs nodev /mnt/huge
echo 2048 | sudo tee /proc/sys/vm/nr_hugepages

# Start LTTng tracing
lttng create dpdk-trace
lttng enable-event -k --function '*'
lttng start

# Run your app (change this as needed)
sudo ./examples/dpdk-l2fwd

# Stop tracing
lttng stop
lttng destroy
```

## 📬 Contact

For issues or improvements, feel free to open an issue or pull request.


