# Benchmarking persistent disk performance

> - Source: <https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance>
> - Captured: 2023-04-06

To benchmark [persistent disk
performance](https://cloud.google.com/compute/docs/disks/performance), use
[FIO](https://fio.readthedocs.io/) instead of other disk benchmarking tools such
as [`dd`](https://en.wikipedia.org/wiki/Dd_(Unix)). By default, `dd` uses a very
low I/O queue depth, so it is difficult to ensure that the benchmark is
generating a sufficient number of I/Os and bytes to accurately test disk
performance.

Additionally, special devices used with `dd` are often very slow and do not
accurately reflect persistent disk performance. In general, avoid using special
devices such as `/dev/urandom`, `/dev/random`, and `/dev/zero` in your
persistent disk performance benchmarks.

To [measure IOPS and throughput of a disk in use on a running
instance](https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance#existing-disk),
benchmark the file system with its intended configuration. Use this option to
test a realistic workload without losing the contents of your existing disk.
Note that when you benchmark the file system on an existing disk, there are many
factors specific to your development environment that may affect benchmarking
results, and you may not reach the [disk performance
limits](https://cloud.google.com/compute/docs/disks/performance).

To [measure the raw performance of a persistent
disk](https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance#raw-disk),
benchmark the block device directly. Use this option to compare raw disk
performance to [disk performance
limits](https://cloud.google.com/compute/docs/disks/performance#type_comparison).

The following commands work with Debian or Ubuntu operating systems with the `apt` package manager.

## Benchmarking IOPS and throughput of a disk on a running instance

If you want to measure IOPS and throughput for a realistic workload on an active disk on a running instance without losing the contents of your disk, benchmark against a new directory on the existing file system.

1. [Connect to your
   instance](https://cloud.google.com/compute/docs/instances/connecting-to-instance).

2. Install dependencies:

    ```shell
    sudo apt updatesudo apt install -y fio
    ```

3. In the terminal, list the disks that are attached to your VM and find the
   disk that you want to test. If your persistent disk is not yet formatted,
   [format and mount the
   disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting).

    ```shell
    sudo lsblk
    ```

    ```shell
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda      8:0    0   10G  0 disk
    └─sda1   8:1    0   10G  0 part /
    sdb      8:32   0  2.5T  0 disk /mnt/disks/mnt_dir  
    ```  

    In this example, we test a 2,500 GB SSD persistent disk with device ID `sdb`.

4. Create a new directory, `fiotest`, on the disk. In this example, the disk is
   mounted at `/mnt/disks/mnt_dir`:

    ```shell
    TEST_DIR=/mnt/disks/mnt_dir/fiotestsudo mkdir -p $TEST_DIR
    ```

5. Test write throughput by performing sequential writes with multiple parallel
   streams (16+), using an I/O block size of 1 MB and an I/O depth of at least
   64:

    ```shell
    sudo fio --name=write_throughput --directory=$TEST_DIR --numjobs=16 \
      --size=10G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
      --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=write \
      --group_reporting=1 --iodepth_batch_submit=64 \
      --iodepth_batch_complete_max=64
    ```

6. Test write IOPS by performing random writes, using an I/O block size of 4 KB
   and an I/O depth of at least 256:

    ```shell
    sudo fio --name=write_iops --directory=$TEST_DIR --size=10G \
      --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
      --verify=0 --bs=4K --iodepth=256 --rw=randwrite --group_reporting=1 \
      --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

7. Test read throughput by performing sequential reads with multiple parallel
   streams (16+), using an I/O block size of 1 MB and an I/O depth of at least
   64:

    ```shell
    sudo fio --name=read_throughput --directory=$TEST_DIR --numjobs=16 \
      --size=10G --time_based --runtime=60s --ramp_time=2s --ioengine=libaio \
      --direct=1 --verify=0 --bs=1M --iodepth=64 --rw=read \
      --group_reporting=1 \
      --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

8. Test read IOPS by performing random reads, using an I/O block size of 4 KB and an I/O depth of at least 256:

    ```shell
    sudo fio --name=read_iops --directory=$TEST_DIR --size=10G \
      --time_based --runtime=60s --ramp_time=2s --ioengine=libaio --direct=1 \
      --verify=0 --bs=4K --iodepth=256 --rw=randread --group_reporting=1 \
      --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

9. Clean up:

    ```shell
    sudo rm $TEST_DIR/write* $TEST_DIR/read*
    ```

## Benchmarking raw persistent disk performance

If you want to measure the performance of persistent disks alone outside of your
development environment, test read and write performance for a block device on a
throwaway persistent disk and VM.

The following commands assume a 2,500 GB SSD persistent disk attached to your
VM. If your device size is different, modify the value of the `--filesize`
argument. This disk size is necessary to achieve the 32 vCPU VM throughput
limits. For more information, see [Block storage
performance](https://cloud.google.com/compute/docs/disks/performance).

> **Warning:**
>
> The commands in this section overwrite the contents of /dev/sdb.
> _We strongly recommend using a throwaway VM and disk_.

1. [Connect to your
   instance](https://cloud.google.com/compute/docs/instances/connecting-to-instance).

2. Install dependencies:

    ```shell
    sudo apt-get updatesudo apt-get install -y fio
    ```

3. Fill the disk with nonzero data. Persistent disk reads from empty blocks have
   a latency profile that is different from blocks that contain data. We
   recommend filling the disk before running any read latency benchmarks.

    ```shell
    # Running this command causes data loss on the second device.
    # We strongly recommend using a throwaway VM and disk.
    sudo fio --name=fill_disk \
      --filename=/dev/sdb --filesize=2500G \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=128K --iodepth=64 --rw=randwrite \
      --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

4. Test write bandwidth by performing sequential writes with multiple parallel
   streams (16+), using 1 MB as the I/O size and having an I/O depth that is
   greater than or equal to 64.

    ```shell
    # Running this command causes data loss on the second device.
    # We strongly recommend using a throwaway VM and disk.
    sudo fio --name=write_bandwidth_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=1M --iodepth=64 --iodepth_batch_submit=64 \
      --iodepth_batch_complete_max=64 \
      --rw=write --numjobs=16 --offset_increment=100G
    ```

5. Test write IOPS. To achieve maximum PD IOPS, you must maintain a deep I/O
   queue. If, for example, the write latency is 1 millisecond, the VM can
   achieve, at most, 1,000 IOPS for each I/O in flight. To achieve 15,000 write
   IOPS, the VM must maintain at least 15 I/Os in flight. If your disk and VM
   are able to achieve 30,000 write IOPS, the number of I/Os in flight must be
   at least 30 I/Os. If the I/O size is larger than 4 KB, the VM might reach the
   bandwidth limit before it reaches the IOPS limit.

    ```shell
    # Running this command causes data loss on the second device.
    # We strongly recommend using a throwaway VM and disk.
    sudo fio --name=write_iops_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=4K --iodepth=256 --rw=randwrite \
      --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

6. Test write latency. While testing I/O latency, the VM must not reach maximum
   bandwidth or IOPS; otherwise, the observed latency won't reflect actual
   persistent disk I/O latency. For example, if the IOPS limit is reached at an
   I/O depth of 30 and the `fio` command has double that, then the total IOPS
   remains the same and the reported I/O latency doubles.

    ```shell
    # Running this command causes data loss on the second device.
    # We strongly recommend using a throwaway VM and disk.
    sudo fio --name=write_latency_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=4K --iodepth=4 --rw=randwrite --iodepth_batch_submit=4 \
      --iodepth_batch_complete_max=4
    ```

7. Test read bandwidth by performing sequential reads with multiple parallel
   streams (16+), using 1 MB as the I/O size and having an I/O depth that is
   equal to 64 or greater.

    ```shell
    sudo fio --name=read_bandwidth_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=1M --iodepth=64 --rw=read --numjobs=16 --offset_increment=100G \
      --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

8. Test read IOPS. To achieve the maximum PD IOPS, you must maintain a deep I/O
   queue. If, for example, the I/O size is larger than 4 KB, the VM might reach
   the bandwidth limit before it reaches the IOPS limit. To achieve the maximum
   100k read IOPS, specify `--iodepth=256` for this test.

    ```shell
    sudo fio --name=read_iops_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=4K --iodepth=256 --rw=randread \
      --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

9. Test read latency. It's important to fill the disk with data to get a
   realistic latency measurement. It's important that the VM not reach IOPS or
   throughput limits during this test because after the persistent disk reaches
   its saturation limit, it pushes back on incoming I/Os and this is reflected
   as an artificial increase in I/O latency.

    ```shell
    sudo fio --name=read_latency_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --bs=4K --iodepth=4 --rw=randread \
      --iodepth_batch_submit=4 --iodepth_batch_complete_max=4
    ```

10. Test sequential read bandwidth.

    ```shell
    sudo fio --name=read_bandwidth_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --numjobs=4 --thread --offset_increment=500G \
      --bs=1M --iodepth=64 --rw=read \
      --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

11. Test sequential write bandwidth.

    ```shell
    sudo fio --name=write_bandwidth_test \
      --filename=/dev/sdb --filesize=2500G \
      --time_based --ramp_time=2s --runtime=1m \
      --ioengine=libaio --direct=1 --verify=0 --randrepeat=0 \
      --numjobs=4 --thread --offset_increment=500G \
      --bs=1M --iodepth=64 --rw=write \
      --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```
