#!/usr/bin/env bash
set -e
export  MONGO_USER=admin
export  MONGO_DB_DEFAULT_PASSWORD=changeme
export  MONGO_INITDB_ROOT_USER=admin
export  MONGO_INITDB_ROOT_DEFAULT_PASSWORD=changeme
export  MONGO_USER_PASSWORD_FILE="mongo-root-passwd"
export  MONGO_DB="test"

 export  ou_member="MyServers"
export  ou_client="MyClients"
export  mongodb_server_hosts=( "mongodb-test-server1" "mongodb-test-server2" "mongodb-test-server3" )
export  mongodb_client_hosts=( "mongodb-test-client1" "mongodb-test-client2" )
export  mongodb_port=27017

cd certs

#OpenSSL CA Certificate for Testing
openssl genrsa -out mongodb-test-ca.key 4096
    cat >openssl-test-ca.cnf <<EOF
    [ policy_match ]
    countryName = match
    stateOrProvinceName = match
    organizationName = match
    organizationalUnitName = optional
    commonName = supplied
    emailAddress = optional



    [ req ]
    default_bits = 4096
    default_keyfile = mongodb-test-ca.pem    ## The default private key file name.
    default_md = sha256                           ## Use SHA-256 for Signatures
    distinguished_name = req_distinguished_name
    req_extensions = v3_req
    x509_extensions = v3_ca # The extentions to add to the self signed cert
    prompt = no

    [req_distinguished_name]
    CN = 127.0.0.1
    C = US
    ST = CA
    L = SB
    O = MongoDBCA
    OU = Cloud

    [ v3_req ]
    subjectKeyIdentifier  = hash
    basicConstraints = CA:FALSE
    keyUsage = critical, digitalSignature, keyEncipherment
    nsComment = "OpenSSL Generated Certificate"
    extendedKeyUsage  = serverAuth, clientAuth


    [ req_dn ]
    countryName = Country Name (2 letter code)
    countryName_default =
    countryName_min = 2
    countryName_max = 2

    stateOrProvinceName = State or Province Name (full name)
    stateOrProvinceName_default = TestCertificateStateName
    stateOrProvinceName_max = 64

    localityName = Locality Name (eg, city)
    localityName_default = TestCertificateLocalityName
    localityName_max = 64

    organizationName = Organization Name (eg, company)
    organizationName_default = TestCertificateOrgName
    organizationName_max = 64

    organizationalUnitName = Organizational Unit Name (eg, section)
    organizationalUnitName_default = TestCertificateOrgUnitName
    organizationalUnitName_max = 64

    commonName = Common Name (eg, YOUR name)
    commonName_max = 64

    [ v3_ca ]
    # Extensions for a typical CA


    subjectKeyIdentifier = hash
    basicConstraints = critical,CA:true
    authorityKeyIdentifier = keyid:always,issuer:always

    # Key usage: this is typical for a CA certificate. However, since it will
    # prevent it being used as a test self-signed certificate it is best
    # left out by default.
    keyUsage = critical,keyCertSign,cRLSign

    [alt_names]
    DNS.1 = 127.0.0.1
    DNS.8 = localhost

EOF
openssl req -new -x509 -days 1826 -key mongodb-test-ca.key -out mongodb-test-ca.crt -config openssl-test-ca.cnf
openssl x509 -noout -text -in mongodb-test-ca.crt

#OpenSSL Intermediate CA Certificate for Testing
openssl genrsa -out mongodb-test-ia.key 4096
openssl req -new -key mongodb-test-ia.key -out mongodb-test-ia.csr -config openssl-test-ia.cnf

openssl x509 -req -days 730 \
  -in mongodb-test-ia.csr \
  -CA mongodb-test-ca.crt \
  -CAkey mongodb-test-ca.key \
  -set_serial 01 \
  -out mongodb-test-ia.crt \
  -extfile openssl-test-ca.cnf \
  -extensions v3_ca

cat mongodb-test-ca.crt > mongodb-test-ca.pem
cat mongodb-test-ia.crt >> ./test-ca.pem

#cat mongodb-test-ca.crt mongodb-test-ia.crt  > test-ca.pem

openssl x509 -in test-ca.pem -inform PEM -subject -nameopt RFC2253
chmod 700 ./test-ca.pem


#OpenSSL Server Certificate for Testing

# Pay attention to the OU part of the subject in "openssl req" command
for host in "${mongodb_server_hosts[@]}"; do
    echo "Generating key for $host"
    STATUS_URI="/hows-it-goin";  MONITOR_IP="10.10.2.15";

    cat >openssl-test-server.cnf <<EOF
[ req ]
default_bits = 4096
default_keyfile = ${host}.pem    ## The default private key file name.
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[ v3_req ]
subjectKeyIdentifier  = hash
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
nsComment = "OpenSSL Generated Certificate for TESTING only.  NOT FOR PRODUCTION USE."
extendedKeyUsage  = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${host}


[req_distinguished_name]
CN = ${host}
C = US
ST = CA
L = SB
O = MongoDBServer
OU = Infrastructure

[ req_dn ]
countryName = Country Name (2 letter code)
countryName_default = TestServerCertificateCountry
countryName_min = 2
countryName_max = 2

stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = TestServerCertificateState
stateOrProvinceName_max = 64

localityName = Locality Name (eg, city)
localityName_default = TestServerCertificateLocality
localityName_max = 64

organizationName = Organization Name (eg, company)
organizationName_default = TestServerCertificateOrg
organizationName_max = 64

organizationalUnitName = Organizational Unit Name (eg, section)
organizationalUnitName_default = TestServerCertificateOrgUnit
organizationalUnitName_max = 64

commonName = Common Name (eg, YOUR name)
commonName_max = 128
EOF
    openssl genrsa -out ${host}.key 4096

	openssl req -new -sha256 -key ${host}.key -out ${host}.csr -config openssl-test-server.cnf

	openssl x509 -req -days 365 -in ${host}.csr -CA mongodb-test-ia.crt -CAkey \
	mongodb-test-ia.key -CAcreateserial -out ${host}.crt -extfile openssl-test-server.cnf \
	-extensions v3_req

    cat ${host}.crt > ${host}.pem
    cat ${host}.key >> ${host}.pem
    openssl x509 -in ${host}.pem -inform PEM -subject -nameopt RFC2253

done


#OpenSSL Server Certificate for Testing
#openssl genrsa -out mongodb-test-server1.key 4096
#openssl req -new -key mongodb-test-server1.key -out mongodb-test-server1.csr -config openssl-test-server.cnf
#openssl x509 -sha256 -req -days 365 -in mongodb-test-server1.csr -CA mongodb-test-ia.crt -CAkey mongodb-test-ia.key -CAcreateserial -out mongodb-test-server1.crt -extfile openssl-test-server.cnf -extensions v3_req
#cat mongodb-test-server1.crt mongodb-test-server1.key > test-server1.pem
#openssl x509 -in test-server1.pem -inform PEM -subject -nameopt RFC2253
#chmod 700 ./test-server1.pem

#OpenSSL Client Certificate for Testing
# Pay attention to the OU part of the subject in "openssl req" command
for host in "${mongodb_client_hosts[@]}"; do
    echo "Generating key for $host"
    openssl genrsa -out ${host}.key 4096
        cat >openssl-test-client.cnf <<EOF
[ req ]
default_bits = 4096
default_keyfile = ${host}.pem    ## The default private key file name.
default_md = sha256
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no
subjectAltName = @alt_names

[req_distinguished_name]
CN = ${host}
C=US
ST=CA
L=SB
O=MongoDBClient
OU=Infrastructure

[ v3_req ]
subjectKeyIdentifier  = hash
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
nsComment = "OpenSSL Generated Certificate for TESTING only.  NOT FOR PRODUCTION USE."
extendedKeyUsage  = serverAuth, clientAuth


[ req_dn ]
countryName = Country Name (2-letter code)
countryName_default = US
countryName_min = 2
countryName_max = 2

stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = CA
stateOrProvinceName_max = 64

localityName = Locality Name (eg, city)
localityName_default = San Bruno
localityName_max = 64

organizationName = Organization Name (eg, company)
organizationName_default = MongoDB
organizationName_max = 64

organizationalUnitName = Organizational Unit Name (eg, section)
organizationalUnitName_default = Infrastructure
organizationalUnitName_max = 64

commonName = Common Name (eg, YOUR name)
commonName_default = ${host}
commonName_max = 64
EOF
    openssl req -new -sha256 -key ${host}.key -out ${host}.csr -config openssl-test-client.cnf
    openssl x509 -req -days 365 -in ${host}.csr -CA mongodb-test-ia.crt -CAkey \
      mongodb-test-ia.key -CAcreateserial -out ${host}.crt -extfile openssl-test-client.cnf \
      -extensions v3_req
    cat ${host}.crt > ${host}.pem
    cat ${host}.key >> ${host}.pem
    openssl x509 -in ${host}.pem -inform PEM -subject -nameopt RFC2253
done


docker-compose down
docker rmi mongo:latest -f
docker volume rm mongo_data -f
docker volume create mongo_data
docker volume rm  mongo_journal -f
docker volume create mongo_journal
docker-compose up --build --force-recreate --remove-orphans -d

#mongosh --tls --host localhost --tlsCertificateKeyFile certs/mongodb_node_1.key --tlsCAFile certs/ca.pem
#mongosh --host localhost --tls \
#    --tlsCertificateKeyFile /Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/dbuser1.pem \
#    --tlsCAFile /Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/ca.pem \
#    --authenticationDatabase '$external' \
#    --authenticationMechanism MONGODB-X509
mongo --tls --verbose --host 127.0.0.1 \
    --tlsCertificateKeyFile "/Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/mongodb-test-client1.pem" \
    --tlsCAFile "/Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/mongodb-test-ia.crt" \
    --authenticationMechanism MONGODB-X509 \
    --authenticationDatabase '$external' \
    --tlsAllowInvalidHostnames  \
    --tlsAllowInvalidCertificates

#mongosh --tls --verbose \
#    --tlsCertificateKeyFile "/Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/dbuser1.pem" \
#    --tlsCAFile "/Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/ca.pem" \
#    --authenticationMechanism MONGODB-X509 \
#    --authenticationDatabase '$external' \
#    --tlsAllowInvalidHostnames  \
#    --tlsAllowInvalidCertificates


#mongosh --host 127.0.0.1 --tls --tlsCertificateKeyFile "/Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/dbuser1.pem" --tlsCAFile "/Users/nicolasfodor/Documents/dev21-host/sturdymongo/certs/ca.pem" --authenticationDatabase '$external' --tlsAllowInvalidHostnames  --tlsAllowInvalidCertificates  --authenticationMechanism MONGODB-X509
#mongosh localhost/admin --tls \
#    -u $MONGO_USER -p '$(cat "$MONGO_USER_PASSWORD_FILE")'
#    --username "CN=127.0.0.1,OU=Cloud,O=MongoDB,L=SB,ST=CA,C=US"
#cd nodejs
#npm install mongodb --save
#node --inspect client.js
#docker-compose logs -f
docker exec -ti mongodb tail /var/log/mongod.log -f
#docker stats

#docker-compose down