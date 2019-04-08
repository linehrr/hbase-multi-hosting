# hbase-multi-hosting
this is a simple and yet hacky way to host multiple regions servers on a single host machine for hbase to solve the beefy server issue

# why
some beefy server(especially under on premise environment) has too much CPU resource that can't be utilized easily by hbase region server due to the lack of multi-thread support.

# how
simply hosting multiple region servers on the same host will properly solve this issue. each region server works independently and will have much better resource utilization afterall. 

# challenge
Ambari not Cloudera manager supports multi-region per host deployment option. therefore we will have to hack it ourselves.

# solution
by shifting ports and folders, we can have multiple region servers running on the same machine peacefully(without each one fighting against others).
by hijacking the start up script, we can achieve this seamlessly and don't have to worry too much about even the version upgrade.

# steps (only tested on HDP)
1. go `/usr/hdp/current/hbase-regionserver/bin/` on each host
2. move `hbase-daemon.sh` to `hbase-daemon-per-instance.sh`, preserve its file attributes(owner and permissions)
3. copy `hbase-daemon.sh` in this repo and set the owner and permission the same as the original one
4. adjust number of regions in the script to the desired number you want(don't over-commit the memory)
5. now go and restart the region server in Ambari 
6. you will see multiple region servers running under hbaseUI now
7. but you won't see muultiple regions under Ambari since it has no idea about those extra ones, we will have to hack `Metric Collector` to get Ambari see multiple region servers per host(that's gonna be hard tho)

# monitoring
one can certainly use hbase REST API endpoint to monitor the health of all those region servers. 
or any other way your creativity could give you :)
