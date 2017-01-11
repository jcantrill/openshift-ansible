#! /bin/sh
set -ex

function generate_JKS_chain() {
    dir=${SCRATCH_DIR:-_output}
    NODE_NAME=$1
    CERT_NAMES=${2:-$NODE_NAME}
    OPENSHIFT_OID=${3:-''}
    ks_pass=${KS_PASS:-kspass}
    ts_pass=${TS_PASS:-tspass}
    rm -rf $NODE_NAME

    extension_names=""
    for name in ${CERT_NAMES//,/ }; do
        extension_names="${extension_names},dns:${name}"
    done

    if [ -n "$OPENSHIFT_OID" ]; then
        extension_names="${extension_names},oid:$OPENSHIFT_OID"
    fi

    echo Generating keystore and certificate for node $NODE_NAME

    keytool -genkey \
        -alias     $NODE_NAME \
        -keystore  $dir/$NODE_NAME.jks \
        -keypass   $ks_pass \
        -storepass $ks_pass \
        -keyalg    RSA \
        -keysize   2048 \
        -validity  712 \
        -dname "CN=$NODE_NAME, OU=OpenShift, O=Logging" \
        -ext san=dns:localhost,ip:127.0.0.1"${extension_names}"

    echo Generating certificate signing request for node $NODE_NAME

    keytool -certreq \
        -alias      $NODE_NAME \
        -keystore   $dir/$NODE_NAME.jks \
        -storepass  $ks_pass \
        -file       $dir/$NODE_NAME.csr \
        -keyalg     rsa \
        -dname "CN=$NODE_NAME, OU=OpenShift, O=Logging" \
        -ext san=dns:localhost,ip:127.0.0.1"${extension_names}"

    echo Sign certificate request with CA

    openssl ca \
        -in $dir/$NODE_NAME.csr \
        -notext \
        -out $dir/$NODE_NAME.crt \
        -config $dir/signing.conf \
        -extensions v3_req \
        -batch \
        -extensions server_ext

    echo "Import back to keystore (including CA chain)"

    keytool  \
        -import \
        -file $dir/ca.crt  \
        -keystore $dir/$NODE_NAME.jks   \
        -storepass $ks_pass  \
        -noprompt -alias sig-ca

    keytool \
        -import \
        -file $dir/$NODE_NAME.crt \
        -keystore $dir/$NODE_NAME.jks \
        -storepass $ks_pass \
        -noprompt \
        -alias $NODE_NAME

    echo All done for $NODE_NAME
}

function generate_JKS_client_cert() {
    NODE_NAME="$1"
    ks_pass=${KS_PASS:-kspass}
    ts_pass=${TS_PASS:-tspass}
    dir=${SCRATCH_DIR:-_output}  # for writing files to bundle into secrets

    echo Generating keystore and certificate for node ${NODE_NAME}

    keytool -genkey \
        -alias     $NODE_NAME \
        -keystore  $dir/$NODE_NAME.jks \
        -keyalg    RSA \
        -keysize   2048 \
        -validity  712 \
        -keypass $ks_pass \
        -storepass $ks_pass \
        -dname "CN=$NODE_NAME, OU=OpenShift, O=Logging"

    echo Generating certificate signing request for node $NODE_NAME

    keytool -certreq \
        -alias      $NODE_NAME \
        -keystore   $dir/$NODE_NAME.jks \
        -file       $dir/$NODE_NAME.jks.csr \
        -keyalg     rsa \
        -keypass $ks_pass \
        -storepass $ks_pass \
        -dname "CN=$NODE_NAME, OU=OpenShift, O=Logging"

    echo Sign certificate request with CA
    openssl ca \
        -in "$dir/$NODE_NAME.jks.csr" \
        -notext \
        -out "$dir/$NODE_NAME.jks.crt" \
        -config $dir/signing.conf \
        -extensions v3_req \
        -batch \
        -extensions server_ext

    echo "Import back to keystore (including CA chain)"

    keytool  \
        -import \
        -file $dir/ca.crt  \
        -keystore $dir/$NODE_NAME.jks   \
        -storepass $ks_pass  \
        -noprompt -alias sig-ca

    keytool \
        -import \
        -file $dir/$NODE_NAME.jks.crt \
        -keystore $dir/$NODE_NAME.jks \
        -storepass $ks_pass \
        -noprompt \
        -alias $NODE_NAME

    echo All done for $NODE_NAME
}

function join { local IFS="$1"; shift; echo "$*"; }

function createTruststore() {

  echo "Import CA to truststore for validating client certs"

  keytool -import -file $dir/ca.crt -keystore $dir/truststore.jks -storepass $ts_pass -noprompt -alias sig-ca
}

dir="$CERT_DIR"
SCRATCH_DIR=$dir

if [[ ! -f $dir/system.admin.jks || -z "$(keytool -list -keystore $dir/system.admin.jks -storepass kspass | grep sig-ca)" ]]; then
  generate_JKS_client_cert "system.admin"
fi

if [[ ! -f $dir/elasticsearch.jks || -z "$(keytool -list -keystore $dir/elasticsearch.jks -storepass kspass | grep sig-ca)" ]]; then
  generate_JKS_chain elasticsearch "$(join , logging-es{,-ops})" ${CERT_OID}
fi

if [[ ! -f $dir/logging-es.jks || -z "$(keytool -list -keystore $dir/logging-es.jks -storepass kspass | grep sig-ca)" ]]; then
  generate_JKS_chain logging-es "$(join , logging-es{,-ops}{,-cluster}{,.${PROJECT}.svc.cluster.local})"
fi

[ ! -f $dir/truststore.jks ] && createTruststore

# necessary so that the job knows it completed successfully
exit 0
