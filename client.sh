export LD_PRELOAD=/usr/lib64/liblttng-ust-cyg-profile.so

/home/amdor/code/kernel_function_tracing/project/dpdk/build/app/dpdk-testpmd  -l 2-3 --proc-type=primary --file-prefix=pmd2 --vdev=net_memif -- -i
