#! /bin/sh

set -ex

keytool -genkey -alias {{component}} -keystore {{generated_certs_dir}}/{{component}}.jks -keypass kspass -storepass kspass \
-keyalg RSA -keysize 2048 -validity 712 -dname "CN={{component}}, OU=OpenShift, O=Logging" {{extensions.stdout}}

keytool -certreq -alias {{component}} -keystore {{generated_certs_dir}}/{{component}}.jks -storepass kspass \
-file {{generated_certs_dir}}/{{component}}-jks.csr -keyalg RSA -dname "CN={{component}}, OU=OpenShift, O=Logging" {{extensions.stdout}}

# this currently fails since we don't provide openssl as part of the ES image...
openssl ca -in {{generated_certs_dir}}/{{component}}-jks.csr -notext -out {{generated_certs_dir}}/{{component}}-jks.crt \
-config {{generated_certs_dir}}/signing.conf -extensions v3_req -batch -extensions server_ext

keytool -import -file {{generated_certs_dir}}/ca.crt -keystore {{generated_certs_dir}}/{{component}}.jks \
-storepass kspass -noprompt -alias sig-ca

keytool -import -file {{generated_certs_dir}}/{{component}}-jks.crt -keystore {{generated_certs_dir}}/{{component}}.jks \
 -storepass kspass -noprompt -alias {{component}}

keytool -import -file {{generated_certs_dir}}/ca.crt -keystore {{generated_certs_dir}}/truststore.jks -storepass tspass -noprompt -alias sig-ca
