## openshift_logging Role

This role is used for installing the Aggregated Logging stack. It should be run against
a single host, it will create any missing certificates and API objects that the current
[logging deployer](https://github.com/openshift/origin-aggregated-logging/tree/master/deployer) does.

###Required vars:

- install_logging: True

###Optional vars:

- image_prefix: The prefix for the logging images to use. Defaults to 'docker.io/openshift/origin-'.
- image_version: The image version for the logging images to use. Defaults to 'latest'.
- logging_use_ops: If 'True', set up a second ES and Kibana cluster for infrastructure logs. Defaults to 'False'.
- master_url: The URL for the Kubernetes master, this does not need to be public facing but should be accessible from within the cluster. Defaults to 'https://kubernetes.default.svc.cluster.local'.
- public_master_url: The public facing URL for the Kubernetes master, this is used for Authentication redirection. Defaults to 'https://localhost:8443'.
- logging_namespace: The namespace that Aggregated Logging will be installed in. Defaults to 'logging'.
- etcd_generated_certs_dir: The path to the etcd generated certs, this role will create its certs in the logging directory at this path. Defaults to ''/etc/etcd/generated_certs'.

- curator_default_days: The default minimum age (in days) Curator uses for deleting log records. Defaults to '30'.
- curator_run_hour: The hour of the day that Curator will run at. Defaults to '0'.
- curator_run_minute: The minute of the hour that Curator will run at. Defaults to '0'.
- curator_run_timezone: The timezone that Curator uses for figuring out its run time. Defaults to 'UTC'.
- curator_script_log_level: The script log level for Curator. Defaults to 'INFO'.
- curator_log_level: The log level for the Curator process. Defaults to 'ERROR'.

- kibana_hostname: The Kibana hostname. Defaults to 'kibana.example.com'.
- kibana_ops_hostname: The Operations Kibana hostname. Defaults to 'kibana-ops.example.com'.
- kibana_proxy_debug: When "True", set the Kibana Proxy log level to DEBUG. Defaults to 'false'.

- fluentd_nodeselector: The node selector that the Fluentd daemonset uses to determine where to deploy to. Defaults to '"logging-infra-fluentd": "true"'.
- fluentd_cpu_limit: The CPU limit for Fluentd pods. Defaults to '100m'.
- fluentd_es_copy: Whether or not to use the ES_COPY feature for Fluentd (DEPRECATED). Defaults to 'False'.
- fluentd_use_journal: Whether or not Fluentd should read log entries from Journal. Defaults to 'False'. NOTE: Fluentd will attempt to detect whether or not Docker is using the journald log driver and may overwrite this value.
- journal_read_from_head: Whether or not Fluentd will try to read from the head of Journal when first starting up, using this may cause a delay in ES receiving current log records. Defaults to 'False'.
- fluentd_hosts: List of nodes that should be labeled for Fluentd to be deployed to. Defaults to ['--all'].

- es_host: The name of the ES service Fluentd should send logs to. Defaults to 'logging-es'.
- es_port: The port for the ES service Fluentd should sent its logs to. Defaults to '9200'.
- es_ca: The location of the ca Fluentd uses to communicate with its es_host. Defaults to '/etc/fluent/keys/ca'.
- es_client_cert: The location of the client certificate Fluentd uses for es_host. Defaults to '/etc/fluent/keys/cert'.
- es_client_key: The location of the client key Fluentd uses for es_host. Defaults to '/etc/fluent/keys/key'.

- es_cluster_size: The number of ES cluster members. Defaults to '1'.
- es_instance_ram: The amount of RAM that should be assigned to ES. Defaults to '1024M'.
- es_pv_selector: A key/value map added to a PVC in order to select specific PVs.  Defaults to 'None'.
- es_pvc_dynamic: Whether or not to add the dynamic PVC annotation for any generated PVCs. Defaults to 'False'.
- es_pvc_size: The requested size for the ES PVCs, when not provided the role will not generate any PVCs. Defaults to '""'.
- es_pvc_prefix: The prefix for the generated PVCs. Defaults to 'logging-es'.
- es_recover_after_time: The amount of time ES will wait before it tries to recover. Defaults to '5m'.
- es_storage_group: The storage group used for ES. Defaults to '65534'.

When `logging_use_ops` is `True`, there are some additional vars. These work the
same as above for their non-ops counterparts, but apply to the OPS cluster instance:
- es_ops_host: logging-es-ops
- es_ops_port: 9200
- es_ops_ca: /etc/fluent/keys/ca
- es_ops_client_cert: /etc/fluent/keys/cert
- es_ops_client_key: /etc/fluent/keys/key
- es_ops_cluster_size: 0
- es_ops_instance_ram: 1024M
- es_ops_pvc_dynamic: False
- es_ops_pvc_size: ""
- es_ops_pvc_prefix: logging-es-ops
- es_ops_recover_after_time: 5m
- es_ops_storage_group: 65534
- ops_host: logging-es-ops
- ops_port: 9200
- ops_client_cert: /etc/fluent/keys/cert
- ops_client_key: /etc/fluent/keys/key
- ops_ca: /etc/fluent/keys/ca
