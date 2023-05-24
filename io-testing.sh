#!/bin/bash

TEST_DIR=/mnt/nfs/acl_lab_v_01/fiotest

################################################################################

runtime_start=$(date --rfc-3339=ns)

if [[ "$(id -u)" != "0" ]]; then
  echo "ERROR: run this as root" >&2
  exit 1
fi

if ! builtin command -v fio &>/dev/null; then
  apt update
  apt install -y fio
fi

cat <<- 'EOF'
Benchmarking persistent disk performance

To benchmark persistent disk performance, use FIO instead of other disk
benchmarking tools such as dd. By default, dd uses a very low I/O queue depth,
so it is difficult to ensure that the benchmark is generating a sufficient
number of I/Os and bytes to accurately test disk performance.

Additionally, special devices used with dd are often very slow and do not
accurately reflect persistent disk performance. In general, avoid using special
devices such as /dev/urandom, /dev/random, and /dev/zero in your persistent disk
performance benchmarks.

To measure IOPS and throughput of a disk in use on a running instance, benchmark
the file system with its intended configuration. Use this option to test a
realistic workload without losing the contents of your existing disk. Note that
when you benchmark the file system on an existing disk, there are many factors
specific to your development environment that may affect benchmarking results,
and you may not reach the disk performance limits.

Source:
  https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance

Note:  Some steps are skipped.
EOF


echo -e "\n--------------------------------------------------------------------"
echo "Step 3: List attached disks"

lsblk


# Step 4:  Create a directory
mkdir -p "$TEST_DIR"


echo -e "\n--------------------------------------------------------------------"
echo "Step 5:  Test write throughput by performing sequential writes with"
echo "  multiple parallel streams (8+), using an I/O block size of 1 MB"
echo "  and an I/O depth of at least 64:"

fio --name=write_throughput --directory="$TEST_DIR" --numjobs=8 \
--size=10G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
--direct=1 --verify=0 --bs=1M --iodepth=64 --rw=write \
--group_reporting=1


echo -e "\n--------------------------------------------------------------------"
echo "Step 6a:  Test write IOPS by performing random writes, using an I/O"
echo "  block size of 4 KB and an I/O depth of at least 64:"

fio --name=write_iops --directory="$TEST_DIR" --size=10G \
--time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
--verify=0 --bs=4K --iodepth=64 --rw=randwrite --group_reporting=1


echo -e "\n--------------------------------------------------------------------"
echo "Step 6b:  Same as 6a, but with a block size of 1M:"

fio --name=write_iops --directory="$TEST_DIR" --size=10G \
--time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
--verify=0 --bs=1M --iodepth=64 --rw=randwrite --group_reporting=1


echo -e "\n--------------------------------------------------------------------"
echo "Step 7:  Test read throughput by performing sequential reads with"
echo "  multiple parallel streams (8+), using an I/O block size of 1 MB"
echo "  and an I/O depth of at least 64:"

fio --name=read_throughput --directory="$TEST_DIR" --numjobs=8 \
--size=10G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
--direct=1 --verify=0 --bs=1M --iodepth=64 --rw=read \
--group_reporting=1


echo -e "\n--------------------------------------------------------------------"
echo "Step 8:  Test read IOPS by performing random reads, using an I/O block"
echo "  size of 4 KB and an I/O depth of at least 64:"

fio --name=read_iops --directory="$TEST_DIR" --size=10G \
--time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
--verify=0 --bs=4K --iodepth=64 --rw=randread --group_reporting=1


echo -e "\n--------------------------------------------------------------------"
echo -n "Step 9:  Clean up:"

rm -f "$TEST_DIR/write"* "$TEST_DIR/read"*
echo " ...done!"

runtime_stop=$(date --rfc-3339=ns)
runtime_epoch1=$(date -d "$runtime_start" +%s.%N)
runtime_epoch2=$(date -d "$runtime_stop" +%s.%N)
runtime=$(bc <<< "$runtime_epoch2 - $runtime_epoch1")

printf "Execution:\n  Started:  %s\n  Stopped:  %s\n  Runtime:  %0.3f second(s)\n" \
  "$runtime_start" "$runtime_stop" "$runtime"

