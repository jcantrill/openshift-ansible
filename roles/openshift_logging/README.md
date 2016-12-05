## openshift_logging Role

### Please note this role is still a work in progress

This role is used for installing the Aggregated Logging stack. It should be run against
a single host, it will create any missing certificates and API objects that the current
[logging deployer](https://github.com/openshift/origin-aggregated-logging/tree/master/deployer) does.

As part of the installation, it is recommended that you add the Fluentd node selector label
to the list of persisted [node labels](https://docs.openshift.org/latest/install_config/install/advanced_install.html#configuring-node-host-labels).

###Required vars:

- openshift_logging_install_logging: True

###Optional vars:

- openshift_logging_image_prefix: The prefix for the logging images to use. Defaults to 'docker.io/openshift/origin-'.
- openshift_logging_image_version: The image version for the logging images to use. Defaults to 'latest'.
- openshift_logging_use_ops: If 'True', set up a second ES and Kibana cluster for infrastructure logs. Defaults to 'False'.
- master_url: The URL for the Kubernetes master, this does not need to be public facing but should be accessible from within the cluster. Defaults to 'https://kubernetes.default.svc.cluster.local'.
- public_master_url: The public facing URL for the Kubernetes master, this is used for Authentication redirection. Defaults to 'https://localhost:8443'.
- openshift_logging_namespace: The namespace that Aggregated Logging will be installed in. Defaults to 'logging'.
- openshift_logging_curator_default_days: The default minimum age (in days) Curator uses for deleting log records. Defaults to '30'.
- openshift_logging_curator_run_hour: The hour of the day that Curator will run at. Defaults to '0'.
- openshift_logging_curator_run_minute: The minute of the hour that Curator will run at. Defaults to '0'.
- openshift_logging_curator_run_timezone: The timezone that Curator uses for figuring out its run time. Defaults to 'UTC'.
- openshift_logging_curator_script_log_level: The script log level for Curator. Defaults to 'INFO'.
- openshift_logging_curator_log_level: The log level for the Curator process. Defaults to 'ERROR'.

- openshift_logging_kibana_hostname: The Kibana hostname. Defaults to 'kibana.example.com'.
- openshift_logging_kibana_ops_hostname: The Operations Kibana hostname. Defaults to 'kibana-ops.example.com'.
- openshift_logging_kibana_proxy_debug: When "True", set the Kibana Proxy log level to DEBUG. Defaults to 'false'.

- openshift_logging_fluentd_nodeselector: The node selector that the Fluentd daemonset uses to determine where to deploy to. Defaults to '"logging-infra-fluentd": "true"'.
- openshift_logging_fluentd_cpu_limit: The CPU limit for Fluentd pods. Defaults to '100m'.
- openshift_logging_fluentd_memory_limit: The memory limit for Fluentd pods. Defaults to '512Mi'.
- openshift_logging_fluentd_es_copy: Whether or not to use the ES_COPY feature for Fluentd (DEPRECATED). Defaults to 'False'.
- openshift_logging_fluentd_use_journal: Whether or not Fluentd should read log entries from Journal. Defaults to 'False'. NOTE: Fluentd will attempt to detect whether or not Docker is using the journald log driver and may overwrite this value.
- openshift_logging_fluentd_journal_read_from_head: Whether or not Fluentd will try to read from the head of Journal when first starting up, using this may cause a delay in ES receiving current log records. Defaults to 'False'.
- openshift_logging_fluentd_hosts: List of nodes that should be labeled for Fluentd to be deployed to. Defaults to ['--all'].

- openshift_logging_es_host: The name of the ES service Fluentd should send logs to. Defaults to 'logging-es'.
- openshift_logging_es_port: The port for the ES service Fluentd should sent its logs to. Defaults to '9200'.
- openshift_logging_es_ca: The location of the ca Fluentd uses to communicate with its openshift_logging_es_host. Defaults to '/etc/fluent/keys/ca'.
- openshift_logging_es_client_cert: The location of the client certificate Fluentd uses for openshift_logging_es_host. Defaults to '/etc/fluent/keys/cert'.
- openshift_logging_es_client_key: The location of the client key Fluentd uses for openshift_logging_es_host. Defaults to '/etc/fluent/keys/key'.

- openshift_logging_es_cluster_size: The number of ES cluster members. Defaults to '1'.
- openshift_logging_es_instance_ram: The amount of RAM that should be assigned to ES. Defaults to '1024M'.
- openshift_logging_es_pv_selector: A key/value map added to a PVC in order to select specific PVs.  Defaults to 'None'.
- openshift_logging_es_pvc_dynamic: Whether or not to add the dynamic PVC annotation for any generated PVCs. Defaults to 'False'.
- openshift_logging_es_pvc_size: The requested size for the ES PVCs, when not provided the role will not generate any PVCs. Defaults to '""'.
- openshift_logging_es_pvc_prefix: The prefix for the generated PVCs. Defaults to 'logging-es'.
- openshift_logging_es_recover_after_time: The amount of time ES will wait before it tries to recover. Defaults to '5m'.
- openshift_logging_es_storage_group: The storage group used for ES. Defaults to '65534'.

When `openshift_logging_use_ops` is `True`, there are some additional vars. These work the
same as above for their non-ops counterparts, but apply to the OPS cluster instance:
- openshift_logging_es_ops_host: logging-es-ops
- openshift_logging_es_ops_port: 9200
- openshift_logging_es_ops_ca: /etc/fluent/keys/ca
- openshift_logging_es_ops_client_cert: /etc/fluent/keys/cert
- openshift_logging_es_ops_client_key: /etc/fluent/keys/key
- openshift_logging_es_ops_cluster_size: 1
- openshift_logging_es_ops_instance_ram: 1024M
- openshift_logging_es_ops_pvc_dynamic: False
- openshift_logging_es_ops_pvc_size: ""
- openshift_logging_es_ops_pvc_prefix: logging-es-ops
- openshift_logging_es_ops_recover_after_time: 5m
- openshift_logging_es_ops_storage_group: 65534
