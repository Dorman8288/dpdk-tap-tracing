# DPDK Tracing with LTTng

This project focuses on enabling **LTTng** (Linux Trace Toolkit Next Generation) function tracing on **DPDK** (Data Plane Development Kit) by building it against the `liblttng-ust-cyg-profile.so` shared library.This library enables lttng to trace every function call by raising an event at the start and end of every fucntion in the compiled binary. We will collect function-level traces during the execution of different **testpmd scenarios**, including initial setup and traffic forwarding and filtering using tap devices. After collecting the traces, we will analyze them using **TraceCompass**, focusing on metrics like **latency**, **function frequency**, and **cache/cycles/instructions** from function entry to exit.

The steps include:

1. Setting up LTTng and dpdk.
2. Running **testpmd** commands with function tracing enabled.
3. adding tap device interfaces to the testmpd and adding flow rules.
4. Analyzing trace data using **TraceCompass**.


## 📦 Prerequisites
* **DPDK**: The Data Plane Development Kit for high-performance networking. you can clone this from https://github.com/DPDK/dpdk.
* **LTTng**: The Linux Trace Toolkit to collect traces of userspace applications. it is available in most major distributions.
* **TraceCompass**: A tool to analyze trace files collected by LTTng.you can get a  binary for your operating system at https://projects.eclipse.org/projects/tools.tracecompass/downloads

Make sure you have the following installed:

* DPDK (more information on the installation method below.)
* LTTng
* TraceCompass
* A Linux environment (Ubuntu or similar is recommended, but the traces have been captured on a device running gentoo with 6.12.16 kernel)


## 🔧 Build DPDK with Function Instrumentation

To enable LTTng function tracing, you need to build DPDK against the `liblttng-ust-cyg-profile.so` shared library.

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
## 🔍 Enable LTTng Tracing

 **Create a Trace script**:

   ```bash
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

   ```
  the time delay should be low because the throughput of events is pretty high and it can overload the system pretty quickly if left uncheked.

---

## 🚀 Run DPDK Application

Now, run **DPDK testpmd** with LTTng function tracing enabled.

### Example Commands:

Run DPDK in **server mode** on cores `0-1`:

```bash
export LD_PRELOAD=/usr/lib64/liblttng-ust-cyg-profile.so
sudo ./dpdk-testpmd -l 0-1 -n 4 \
  --vdev=net_tap0,iface=tap0 \
  --vdev=net_tap1,iface=tap1 -- -i --rxd=1024 --txd=1024 --rxq=2 --txq=2 --port-topology=chained
```

now we should add the following flow rules:
```bash
testpmd> flow create 0 ingress pattern eth / ipv4 / tcp / end actions queue index 0 / end
testpmd> flow create 0 ingress pattern eth / ipv4 / udp / end actions queue index 1 / end
```
one for tcp traffic and one for udp traffic.

then using tcpdump capture traffic on one of your active interfaces and save it in a pcap file. 
then input this pcap file to the tap 0 interface using the tcpreplay application. (you may have to recompile tcpreplay for tap functionality to work.)
then use the start command on the testmpd and watch the tap 1 interface with tshark to make sure testmpd is forwarding the packets.

---

## 📊 Analyze the Results
![Alt text](./1l.png)
---


