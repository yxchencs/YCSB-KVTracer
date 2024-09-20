# YCSB-KVTracer

## Overview

YCSB-KVTracer integrates YCSB and KVTracer to achieve the function of generating customized Trace, the main code repositories used are as follows:

- [YCSB](https://github.com/brianfrankcooper/YCSB.git)
- [KVTracer](https://github.com/seekstar/kvtracer.git)

## Quick start

### 1. Command-line approach

1. load

```shell
bin/ycsb.bat load kvtracer -P workloads/workload -p "kvtracer.tracefile=trace_load.txt" -p "kvtracer.keymapfile=trace_keys.txt"
```

2. run

```shell
bin/ycsb.bat run kvtracer -P workloads/workload -p "kvtracer.tracefile=trace_run.txt" -p "kvtracer.keymapfile=trace_keys.txt"
```

### 2. Integration approach

```shell
bash ycsb_run.sh
```

The `ycsb_run.sh` file needs to be placed in the same directory as the `workloads` folder, and the `TARGET_WORKLOAD_DIR` can be modified as needed, with the following contents:

```bash
TARGET_WORKLOAD_DIR="workloads/**"
# Iterate through each subdirectory of the workloads folder
for workload_subdir in $TARGET_WORKLOAD_DIR; do
    if [ -d "$workload_subdir" ]; then
        echo "process dir: $workload_subdir"

        # Generate trace files with YCSB
        ./bin/ycsb.sh load kvtracer -P "$workload_subdir/workload" -p "kvtracer.tracefile=trace_load.txt" -p "kvtracer.keymapfile=trace_keys.txt"
        ./bin/ycsb.sh run kvtracer -P "$workload_subdir/workload" -p "kvtracer.tracefile=trace_run.txt" -p "kvtracer.keymapfile=trace_keys.txt"

        # Move the trace_run.txt file to the workload directory
        sudo mv "trace_run.txt" "$workload_subdir/"
    fi
done
```

**Note: This file is for Linux and Mac only, for Windows, change `. /bin/ycsb.sh` to `. /bin/ycsb.bat`**


## Self-configuration tutorial for YCSB compiled KVTracer module (optional)

The following steps have been performed on this repository and are available for immediate use. If you are interested in learning about the configuration process or would like to configure it yourself, please refer to the following process.

### 0. Adaptation environment

- OS: Ubuntu / Windows / Mac
- Requirements: Maven 3

> Windows and Mac systems in the modification of the file will be opened with Notepad to modify the file can be.

### 1. Clone `YCSB`

```shell
git clone https://github.com/brianfrankcooper/YCSB.git
```

### 2. Go to the `YCSB` root directory

```shell
cd YCSB/
```

### 3. Clone `kvtracer`

```shell
git clone https://github.com/seekstar/kvtracer.git
```

### 4. Change the `pom.xml` file in the `YCSB` root directory to include `kvtracer`.

```shell
sudo vim pom.xml
```

As indicated in the `+` line.

```xml
  <properties>
    ...
    <redis.version>2.0.0</redis.version>
+   <kvtracer.version>0.1.0</kvtracer.version>
    ...
  </properties>
  <modules>
    ...
    <module>redis</module>
+   <module>kvtracer</module>
    ...
  </modules>
```

### 5. Modify `bin/ycsb` in `YCSB` to include `kvtracer`.

```shell
sudo vim bin/ycsb
```

As indicated in the `+` line.

```shell
DATABASES = {
    ...
    "redis"        : "site.ycsb.db.RedisClient",
+   "kvtracer"     : "site.ycsb.db.KVTracerClient",
    ...
}
```

### 6. Modify `bin/bindings.properties` in `YCSB` to include `kvtracer`.

```shell
sudo vim bin/bindings.properties
```

As indicated in the `+` line.

```shell
    redis:site.ycsb.db.RedisClient
+   kvtracer:site.ycsb.db.KVTracerClient
```

### 7. Compile

```shell
mvn -pl kvtracer -am clean package
```

> Please configure Maven 3 in advance as required.

### 8. Run the YCSB command to generate Trace

#### 8.1 Run command

##### 8.1.1 On Linux or Mac

```shell
bin/ycsb.sh load kvtracer -P workloads/workloada -p "kvtracer.tracefile=tracea_load.txt" -p "kvtracer.keymapfile=tracea_keys.txt"
```

and

```shell
bin/ycsb.sh run kvtracer -P workloads/workloada -p "kvtracer.tracefile=tracea_run.txt" -p "kvtracer.keymapfile=tracea_keys.txt"
```

##### 8.1.2 On Windows

```shell
bin/ycsb.bat load kvtracer -P workloads/workloada -p "kvtracer.tracefile=tracea_load.txt" -p "kvtracer.keymapfile=tracea_keys.txt"
```

and

```shell
bin/ycsb.bat run kvtracer -P workloads/workloada -p "kvtracer.tracefile=tracea_run.txt" -p "kvtracer.keymapfile=tracea_keys.txt"
```

#### 8.2 Configuration Parameters Explained

The `workload` file can be customized in the `workloads/` directory to generate different traces on demand. the important parameters are explained next.

##### 8.2.1 ZIPFIAN_CONSTANT

In `YCSB\core\src\main\java\site\ycsb\generator\ZipfianGenerator.java`, the `ZIPFIAN_CONSTANT` parameter is a key configuration item that defines the degree of skewness of the key distribution in the load

The Zipfian distribution is a probability distribution that describes how some items in data are accessed much more frequently than others. In the Zipfian distribution, the frequency of the nth most frequent element is proportional to 1/n.

ZIPFIAN_CONSTANT (Zipfian constant) is used to adjust the degree of skewness of this distribution:

* As `ZIPFIAN_CONSTANT` approaches 0, the distribution approaches a uniform distribution, i.e., all items are visited with roughly equal probability.
* As `ZIPFIAN_CONSTANT` increases, the distribution becomes more skewed. Smaller key values are more likely to be accessed more frequently, while most other key values are accessed less frequently.

A typical `ZIPFIAN_CONSTANT` value is 0.99, which is a reasonable approximation in many real-world scenarios, such as web page accesses, city population distributions, and so on.

##### 8.2.2 recordcount

In the `workload` file, the `recordcount` parameter specifies the number of records to be inserted during the load phase, or the number of records that will already exist in the table before the run phase begins. If `recordcount` is set to 1000000, this means that one million records will be operated on in the database.

##### 8.2.3 operationcount

In the `workload` file, the `operationcount` parameter defines the total number of operations that will be performed during the run phase.
If `operationcount` is set to 150000, it means that 150000 database operations (e.g., read, update, insert, etc.) will be performed during the test.

##### 8.2.4 requestdistribution

In the `workload` file, the `requestdistribution` parameter defines how requests for keyspace are distributed, which is categorized as zipfian, uniform, and latest.