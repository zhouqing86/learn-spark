
学习Hadoop与Spark
=================================

环境: Mac OS

创建虚拟机
-------------------------------
```
gem install foreman
foreman start -f Procfile.dev
ln -s op.sh op
```
op.sh 是自己为了操作虚拟机方便而写的一个简单的shell版本。

op的命令如
```
op [start|s|stop|p|ssh|c|reload|r|provision|v|status|st] [node1|node2|node3]
```

安装Hadoop前准备
-----------------------------
1. 更新每个虚拟机上的/etc/hosts文件，使得其可以解析node1,node2,node3
```
192.168.33.201 node1
192.168.33.202 node2
192.168.33.203 node3
```
2. 在node1 node2 node3上`sudo su -`到root用户后分别执行:
```
ssh-keygen -t rsa
touch authorized_keys
```
而后将每个虚拟机上的id_rsa.pub内容复制到各个虚拟机的authorized_keys中。
而后在每个虚拟机上都分别ssh node1, node2, node3。看是否可以免密码ssh。

3. 安装JAVA
如果对`ansible`等配置工具比较熟悉的话可以尝试用配置的方式管理，这里用最笨的方法在每台虚拟上手动安装。
JDK 1.7 下载: http://www.oracle.com/technetwork/cn/java/javase/downloads/jdk7-downloads-1880260.html
```
cd /vagrant_downloads/
tar zxvf jdk-7u79-linux-x64.tar.gz -C /opt/
```
在.bashrc最后添加
```
export JAVA_HOME=/opt/jdk1.7.0_79
export PATH=$JAVA_HOME/bin:$PATH
```
而后
```
source ~/.bashrc
```

`java -version`查看java是否安装成功

配置Hadoop
------------------------------------
对每一台虚拟机都做同样的配置。
1. 下载和安装
下载hadoop 2.6.2的包:
http://mirrors.cnnic.cn/apache/hadoop/common/hadoop-2.6.2/hadoop-2.6.2.tar.gz

```
cd /vagrant_downloads/
tar zxvf hadoop-2.6.2.tar.gz -C /opt/
```

在.bashrc最后添加
```
export HADOOP_HOME=/opt/hadoop-2.6.2
export PATH=$HADOOP_HOME/bin:$PATH
```

然后
```
source ~/.bashrc
```

创建hdfs使用的目录
```
cd $HADOOP_HOME
mkdir tmp
mkdir -p dfs/name
mkdir -p dfs/data
```

2. 配置Hadoop
http://hadoop.apache.org/docs/r2.6.2/
配置文件的备份在目录`node1/hadoop_configuration`下

```
cd $HADOOP_HOME/etc/hadoop
```


##### vim hadoop_env.sh

在文件中添加修改JAVA_HOME`export JAVA_HOME=/opt/jdk1.7.0_79`

##### vim yarn_env.sh

在文件中添加修改JAVA_HOME`export JAVA_HOME=/opt/jdk1.7.0_79`

##### vim mapred-env.sh

在文件中添加修改JAVA_HOME`export JAVA_HOME=/opt/jdk1.7.0_79`

##### vim slaves

文件内容为
```
node2
node3
```

##### vim core-site.xml
```
<configuration>
  <property>  
         <name>fs.defaultFS</name>  
         <value>hdfs://node1:9000</value>  
  </property>
  <property>  
         <name>hadoop.tmp.dir</name>  
         <value>/opt/hadoop-2.6.2/tmp</value>  
         <description>Abase for other temporary directories.</description>  
  </property>
</configuration>
```

##### vim hdfs-site.xml
```
<configuration>
  <property>
          <name>dfs.namenode.secondary.http-address</name>
          <value>node1:9001</value>
  </property>
  <property>
          <name>dfs.namenode.name.dir</name>
          <value>/opt/hadoop-2.6.2/tmp/dfs/name</value>
  </property>
  <property>
          <name>dfs.datanode.data.dir</name>
          <value>/opt/hadoop-2.6.2/tmp/dfs/data</value>
  </property>
  <property>
          <name>dfs.replication</name>
          <value>2</value>
  </property>
  <property>
          <name>dfs.webhdfs.enabled</name>
          <value>true</value>
  </property>
</configuration>
```

##### vim mapred-site.xml
cp mapred-site.xml.template mapred-site.xml
```
<configuration>
  <property>
          <name>mapreduce.framework.name</name>
          <value>yarn</value>
  </property>
  <property>
          <name>mapreduce.jobhistory.address</name>
          <value>node1:10020</value>
  </property>
  <property>
          <name>mapreduce.jobhistory.webapp.address</name>
          <value>node1:19888</value>
  </property>
</configuration>
```

##### vim yarn-site.xml
```
<configuration>
  <property>
          <name>yarn.nodemanager.aux-services</name>
          <value>mapreduce_shuffle</value>
  </property>
  <property>
          <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
          <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>
  <property>
          <name>yarn.resourcemanager.address</name>
          <value>node1:8032</value>
  </property>
  <property>
          <name>yarn.resourcemanager.scheduler.address</name>
          <value>node1:8030</value>
  </property>
  <property>
          <name>yarn.resourcemanager.resource-tracker.address</name>
          <value>node1:8031</value>
  </property>
  <property>
          <name>yarn.resourcemanager.admin.address</name>
          <value>node1:8033</value>
  </property>
  <property>
          <name>yarn.resourcemanager.webapp.address</name>
          <value>node1:8088</value>
  </property>
</configuration>
```
运行hadoop
--------------------------------------------
格式化hdfs文件系统
```
hadoop namenode -format
```
执行sbin下的`start-all.sh`脚本(目前这个脚本已经被deprecated了)
建议分别使用`start-dfs.sh`和`start-yarn.sh`

Console的log类似于下
```
This script is Deprecated. Instead use start-dfs.sh and start-yarn.sh
Starting namenodes on [node1]
node1: starting namenode, logging to /opt/hadoop-2.6.2/logs/hadoop-root-namenode-node1.out
node3: starting datanode, logging to /opt/hadoop-2.6.2/logs/hadoop-root-datanode-node3.out
node2: starting datanode, logging to /opt/hadoop-2.6.2/logs/hadoop-root-datanode-node2.out
Starting secondary namenodes [node1]
node1: starting secondarynamenode, logging to /opt/hadoop-2.6.2/logs/hadoop-root-secondarynamenode-node1.out
starting yarn daemons
starting resourcemanager, logging to /opt/hadoop-2.6.2/logs/yarn-root-resourcemanager-node1.out
node3: starting nodemanager, logging to /opt/hadoop-2.6.2/logs/yarn-root-nodemanager-node3.out
node2: starting nodemanager, logging to /opt/hadoop-2.6.2/logs/yarn-root-nodemanager-node2.out
```

可以在node1,node2,node3上用`jps`查看虚拟机上hadoop进程的状态。

网页打开http://node1:50070/ 可以查看到hadoop的状态。

http://node1:8088/cluster 查看resourcemanager的状况。

http://node2:8042/node查看nodemanager的状况

##### 启动Job history server
```
./mr-jobhistory-daemon.sh start historyserver
```
通过web访问：http://node1:19888

hdfs操作和hadoop任务执行
--------------------------------
hadoop fs -mkdir /input
hadoop fs -ls /
hadoop fs -copyFromLocal test1.txt /input/
hadoop fs -copyFromLocal test2.txt /input/Sinatra works really well for the API, and smaller sites (internal apps, GitHub Jobs, etc).

cd $HADOOP_HOME/share/hadoop/mapreduce
hadoop jar hadoop-mapreduce-examples-2.6.2.jar wordcount /input /output

导出vagrant box
--------------------------------
关闭虚拟机，进入virtual box directory（~/VirtualBox VM/node3_default_1449057373394_49033)
```
vagrant package --output hadoop_slave.box --base node3_default_1449057373394_49033
```


重新启动datanode后启动相关进程的方法
--------------------------------
```
cd $HADOOP_HOME
sbin/hadoop-daemon.sh start datanode
sbin/yarn-daemon.sh start nodemanager
```

以上是构建本地学习用的Hadoop集群的步骤。

构建Spark集群
--------------------------------
上面描述的都是构建本地学习用的Hadoop集群的步骤。

1. 安装Spark前准备
1) 下载Scala，并将下载的包放到downloads下
http://www.scala-lang.org/download/2.10.4.html

2) 登陆每个节点安装scala
```
cd /vagrant_downloads/ && tar zxvf scala-2.10.4.tgz -C /opt/
vim ~/.bashrc
export SCALA_HOME=/opt/scala-2.10.4
export PATH=$SCALA_HOME/bin:$PATH

source ~/.bashrc
scala -version
```

2. 下载和配置Spark
个人经验在家使用迅雷下载速度快
http://apache.dataguru.cn/spark/spark-1.5.2/spark-1.5.2-bin-hadoop2.6.tgz

```
cd /vagrant_downloads/ && tar zxvf spark-1.5.2-bin-hadoop2.6.tgz -C /opt/
```
```
vim ~/.bashrc
export SPARK_HOME=/opt/spark-1.5.2-bin-hadoop2.6
export PATH=$SPARK_HOME/bin:$PATH
```

```
source ~/.bashrc
```

##### 配置Spark slaves
```
cd $SPARK_HOME/conf
cp slaves.template slaves
vim slaves
```
修改内容为
```
node2
node3
```


##### vim spark-env.sh
cp spark-env.sh.template spark-env.sh

在其中增加内容：
```
export SCALA_HOME=/opt/scala-2.10.4
export JAVA_HOME=/opt/jdk1.7.0_79
export HADOOP_HOME=/opt/hadoop-2.6.2
export HADOOP_CONF_DIR=/opt/hadoop-2.6.2/etc/hadoop
export SPARK_MASTER_IP=node1
export SPARK_WORKER_MEMORY=1g
```

##### 启动Spark
$SPARK_HOME/sbin/start-all.sh
这时log出现error信息
```
starting org.apache.spark.deploy.master.Master, logging to /opt/spark-1.5.2-bin-hadoop2.6/sbin/../logs/spark-root-org.apache.spark.deploy.master.Master-1-node1.out
failed to launch org.apache.spark.deploy.master.Master:
  # An error report file with more information is saved as:
  # /opt/spark-1.5.2-bin-hadoop2.6/hs_err_pid10438.log
full log in /opt/spark-1.5.2-bin-hadoop2.6/sbin/../logs/spark-root-org.apache.spark.deploy.master.Master-1-node1.out
node2: starting org.apache.spark.deploy.worker.Worker, logging to /opt/spark-1.5.2-bin-hadoop2.6/sbin/../logs/spark-root-org.apache.spark.deploy.worker.Worker-1-node2.out
node3: starting org.apache.spark.deploy.worker.Worker, logging to /opt/spark-1.5.2-bin-hadoop2.6/sbin/../logs/spark-root-org.apache.spark.deploy.worker.Worker-1-node3.out
```

可以看出内存不足导致，需要修改虚拟机器node1的内存。在node1的Vagrantfile中增加配置

```
config.vm.provider "virtualbox" do |v|
  v.memory = 2048
  v.cpus = 2
end
```

而后`vagrant reload`

启动hadoop和spark后，可以查看`jps`在node1看到`master`进程，node2和node3中看到`worker`进程。

登陆http://node1:8080/ 可以查看spark集群的web页面。

##### spark-shell
此时,我们进入 Spark 的 bin 目录,使用“spark-shell”控制台:
```
$SPARK_HOME/bin/spark-shell
```
此时则可以通过http://node1:4040/environment/查看spark的环境变量。

至此,Spark集群搭建成功!

##### 测试Spark集群。
```
cd $SPARK_HOME;
hdfs dfs -put README.md /input
MASTER=spark://node1:7077 $SPARK_HOME/bin/spark-shell
```

而后在spark-shell上执行如下代码，例子是来自于spark的quick start：
```
val file=sc.textFile("hdfs://node1:9000/input/README.md")
file.count
file.first()
file.filter(lines => lines.contains("Spark")).count
```

Find the line with the most words:
```
file.map(line => line.split(" ").size).reduce((a, b) => if (a > b) a else b)
```
This first maps a line to an integer value, creating a new RDD. reduce is called on that RDD to find the largest line count. The arguments to map and reduce are Scala function literals (closures), and can use any language feature or Scala/Java library.

One common data flow pattern is MapReduce, as popularized by Hadoop. Spark can implement MapReduce flows easily:
```
val count=file.flatMap(line => line.split(" ")).map(word => (word,1)).reduceByKey(_+_)
count.collect
```

注意这里文件是存储在hdfs上的，与http://spark.apache.org/docs/latest/quick-start.html例子稍有不同。


Spark includes several samples in the examples directory (Scala, Java, Python, R). You can run them as follows:
```
# For Scala and Java, use run-example:
./bin/run-example SparkPi

# For Python examples, use spark-submit directly:
./bin/spark-submit examples/src/main/python/pi.py

# For R examples, use spark-submit directly:
./bin/spark-submit examples/src/main/r/dataframe.R

```

##### Spark集群开发
http://mmicky.blog.163.com/blog/static/150290154201431410313342/
开发时建议本地起Spark服务。我链接远端的QA环境一直失败，猜测是路径不一致造成的。

使用IDEA开发SPARK提交remote cluster执行:
http://www.cnblogs.com/gaoxing/p/4414362.html
注意的一点是：选择scala版本，需要spark的scala版本对应

Spark通过IntelliJ IDEA远程调试
http://www.aboutyun.com/thread-9877-1-1.html
