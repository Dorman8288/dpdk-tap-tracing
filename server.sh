export LD_PRELOAD=/usr/lib64/liblttng-ust-cyg-profile.so

/home/amdor/code/kernel_function_tracing/project/dpdk/build/app/dpdk-testpmd -l 0-1 --proc-type=primary --file-prefix=pmd1 --vdev=net_memif,role=server -- -i
