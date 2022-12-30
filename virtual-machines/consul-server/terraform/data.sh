
#!/bin/bash -xe
service consul stop
cat > /etc/consul.d/consul.json <<EOF
{
    "bootstrap_expect": 5,
    "raft_protocol": 3,
    "client_addr": "0.0.0.0",
    "datacenter": "us-east-1",
    "data_dir": "/opt/consul",
    "enable_script_checks": true,
    "telemetry": {
      "prometheus_retention_time": "1h"
    },
    "dns_config": {
        "enable_truncate": true,
        "only_passing": true
    },
    "enable_syslog": true,
    "leave_on_terminate": true,
    "log_level": "INFO",
    "rejoin_after_leave": true,
    "server": true,
      "retry_join": ["provider=aws tag_key=Application tag_value=Consul"],
    "ui": true,
    "connect": {
	 "enabled": true
         }
}
EOF
rm -rf /opt/consul/checkpoint-signature
rm -rf /opt/consul/node-id 
rm -rf /opt/consul/raft/ 
rm -rf /opt/consul/serf/
service consul restart 