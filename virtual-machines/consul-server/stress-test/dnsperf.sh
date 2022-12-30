 #!/bin/bash -xe

 # Following command sends 5000 dns queries per second to consul server to resolve the dns addresses listed in the file named test
 # This can be changed according to requirements
 ./dnsperf -s  CONSUL_IP_1 -p 8600  -d test  -l 300  -c 5  -Q 5000