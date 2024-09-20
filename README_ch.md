# YCSB-KVTracer

## 概述

YCSB-KVTracer整合了YCSB和KVTracer，实现了生成自定义Trace的功能，主要使用的代码仓库如下：

- [YCSB](https://github.com/brianfrankcooper/YCSB.git)
- [KVTracer](https://github.com/seekstar/kvtracer.git)

## 快速开始

### 1. 命令行方式

1. load

```shell
bin/ycsb.bat load kvtracer -P workloads/workload -p "kvtracer.tracefile=trace_load.txt" -p "kvtracer.keymapfile=trace_keys.txt"
```

2. run

```shell
bin/ycsb.bat run kvtracer -P workloads/workload -p "kvtracer.tracefile=trace_run.txt" -p "kvtracer.keymapfile=trace_keys.txt"
```

### 2. 集成方式

```shell
bash ycsb_run.sh
```

`ycsb_run.sh`文件需与 `workloads`文件夹置于同目录，可按需修改`TARGET_WORKLOAD_DIR`，其中内容如下：

```bash
TARGET_WORKLOAD_DIR="workloads/**"
# 遍历 workloads 文件夹下的每个子目录
for workload_subdir in $TARGET_WORKLOAD_DIR; do
    if [ -d "$workload_subdir" ]; then
        echo "process dir: $workload_subdir"

        # 使用 YCSB 生成 trace 文件
        ./bin/ycsb.sh load kvtracer -P "$workload_subdir/workload" -p "kvtracer.tracefile=trace_load.txt" -p "kvtracer.keymapfile=trace_keys.txt"
        ./bin/ycsb.sh run kvtracer -P "$workload_subdir/workload" -p "kvtracer.tracefile=trace_run.txt" -p "kvtracer.keymapfile=trace_keys.txt"

        # 将 trace_run.txt 文件移动到 workload 目录
        sudo mv "trace_run.txt" "$workload_subdir/"
    fi
done
```

**注意：此文件仅适用于Linux和Mac，若为Windows，则需将 `./bin/ycsb.sh`改为 `./bin/ycsb.bat`**

## YCSB编译KVTracer模块的自行配置教程（可选）

本仓库已进行了以下步骤，可供直接使用。如有兴趣了解配置过程或想要自行配置，请参阅以下过程。

### 0. 适配环境

- OS: Ubuntu / Windows / Mac
- Requirements: Maven 3

> Windows系统和Mac系统在修改文件时将文件用记事本打开修改即可

### 1. 克隆 `YCSB`

```shell
git clone https://github.com/brianfrankcooper/YCSB.git
```

### 2. 进入 `YCSB`根目录

```shell
cd YCSB/
```

### 3. 克隆 `kvtracer`

```shell
git clone https://github.com/seekstar/kvtracer.git
```

### 4. 将 `YCSB` 根目录下的 `pom.xml` 文件修改为包含 `kvtracer`

```shell
sudo vim pom.xml
```

如 `+`所在行所示

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

### 5. 修改 `YCSB` 中的 `bin/ycsb` 以包括 `kvtracer`

```shell
sudo vim bin/ycsb
```

如 `+`所在行所示

```shell
DATABASES = {
    ...
    "redis"        : "site.ycsb.db.RedisClient",
+   "kvtracer"     : "site.ycsb.db.KVTracerClient",
    ...
}
```

### 6. 修改 `YCSB` 中的 `bin/bindings.properties` 以包括 `kvtracer`

```shell
sudo vim bin/bindings.properties
```

如 `+`所在行所示

```shell
    redis:site.ycsb.db.RedisClient
+   kvtracer:site.ycsb.db.KVTracerClient
```

### 7. 编译

```shell
mvn -pl kvtracer -am clean package
```

> 请提前按需求配置Maven 3

### 8. 运行YCSB命令生成Trace

#### 8.1 运行命令

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

#### 8.2 配置参数解释

在 `workloads/`目录中可以自定义 `workload`文件，可按需生成不同的trace。接下来对重要的参数进行解释。

##### 8.2.1 ZIPFIAN_CONSTANT

在 `YCSB\core\src\main\java\site\ycsb\generator\ZipfianGenerator.java`中， `ZIPFIAN_CONSTANT` 参数是一个关键的配置项，用于定义负载中键分布的偏斜程度

Zipfian 分布是一种用于描述数据中某些项目被访问频率远高于其他项目的情况的概率分布。在 Zipfian 分布中，第 n 个最频繁的元素的频率与 1/n 成正比。ZIPFIAN_CONSTANT（Zipfian 常数）用于调整这种分布的偏斜程度：

* 当 `ZIPFIAN_CONSTANT`接近 0 时，分布接近均匀分布，即所有项目被访问的概率大致相等。
* 当 `ZIPFIAN_CONSTANT`增加时，分布变得更加偏斜。较小的键值更有可能被频繁访问，而大部分其他键值则访问频率较低。

一个典型的 `ZIPFIAN_CONSTANT`值是 0.99，这在许多真实世界的场景中是一个合理的近似，例如网页访问、城市人口分布等。

##### 8.2.2 recordcount

在 `workload`文件中，`recordcount `参数指定了在负载阶段要插入的记录数，或者在运行阶段开始前表中已经存在的记录数。 若 `recordcount` 被设置为 1000000，这意味着将有一百万条记录在数据库中进行操作。

##### 8.2.3 operationcount

在 `workload`文件中，`operationcount`参数定义了在运行阶段期间将执行的操作总数。
若 `operationcount`被设置为 150000，表示测试期间将执行 150000 个数据库操作（如读取、更新、插入等）。

##### 8.2.4 requestdistribution

在 `workload`文件中，`requestdistribution`参数定义了对键空间（keyspace）的请求分布方式，分为zipfian，uniform和latest。
