#!/bin/bash

cd /out

if [ -z "$CERTPREFIX" ]; then
    CERTPREFIX=test
fi

# Create a self-signed cert
openssl req -passout pass:"rootpass" -subj "/C=GB/CN=www.$CERTPREFIX-rootca.co.uk" -x509 -newkey rsa:4096 \
-keyout $CERTPREFIX-rootca.key -out $CERTPREFIX-rootca.pem -sha256 -days 365

# Create FIRST INTERMEDIATE certificate signing request (CSR)
openssl req -new -newkey rsa:4096 -passout pass:"intpass" -subj "/C=GB/CN=www.$CERTPREFIX-intcaone.co.uk" -keyout \
$CERTPREFIX-intcaone.key -sha256 -out $CERTPREFIX-intcaone.csr

# Create FIRST INTERMEDIATE cert using the CSR and sign with ROOT cert/key. Use -CAcreateserial to create a serial file.
# Subsequent signings by the root cert will need to point to this serial file using -CAserial instead
openssl x509 -req -passin pass:"rootpass" -CA ./$CERTPREFIX-rootca.pem -CAkey ./$CERTPREFIX-rootca.key -in ./$CERTPREFIX-intcaone.csr \
-out ./$CERTPREFIX-intcaone.pem -extensions v3_ca -CAcreateserial -extfile /certs-config/ca-true.conf

# Create a SECOND INTERMEDIATE certificate signing request (CSR)
openssl req -new -newkey rsa:4096 -passout pass:"intpass" -subj "/C=GB/CN=www.$CERTPREFIX-intcatwo.co.uk" -keyout \
$CERTPREFIX-intcatwo.key -sha256 -out $CERTPREFIX-intcatwo.csr

# Create a SECOND INTERMEDIATE cert and sign with the FIRST INTERMEDIATE cert/key.
openssl x509 -req -passin pass:"intpass" -CA ./$CERTPREFIX-intcaone.pem -CAkey ./$CERTPREFIX-intcaone.key -in ./$CERTPREFIX-intcatwo.csr \
-out ./$CERTPREFIX-intcatwo.pem -extensions v3_ca -CAcreateserial -extfile /certs-config/ca-true.conf

# Create a FIRST CLIENT certificate signing request (CSR).
openssl req -new -newkey rsa:4096 -passout pass:"clientpass" -subj "/C=GB/CN=$CERTPREFIX-client-rootsigned" -keyout \
$CERTPREFIX-client-rootsigned.key -sha256 -out $CERTPREFIX-client-rootsigned.csr

# Create FIRST CLIENT cert signed with ROOT cert/key.
openssl x509 -req -passin pass:"rootpass" -CA ./$CERTPREFIX-rootca.pem -CAkey ./$CERTPREFIX-rootca.key -in ./$CERTPREFIX-client-rootsigned.csr \
-out ./$CERTPREFIX-client-rootsigned.pem -extensions v3_ca -CAserial $CERTPREFIX-rootca.srl -extfile /certs-config/ca-false.conf

# Create a SECOND CLIENT certificate signing request (CSR).
openssl req -new -newkey rsa:4096 -passout pass:"clientpass" -subj "/C=GB/CN=$CERTPREFIX-client-intcaone-signed" -keyout \
$CERTPREFIX-client-intcaone-signed.key -sha256 -out $CERTPREFIX-client-intcaone-signed.csr

# Create SECOND CLIENT cert and sign with INTERMEDIATE ONE cert/key.
openssl x509 -req -passin pass:"intpass" -CA ./$CERTPREFIX-intcaone.pem -CAkey ./$CERTPREFIX-intcaone.key -in ./$CERTPREFIX-client-intcaone-signed.csr \
-out ./$CERTPREFIX-client-intcaone-signed.pem -extensions v3_ca -CAserial $CERTPREFIX-intcaone.srl -extfile /certs-config/ca-false.conf

# Create a THIRD CLIENT certificate signing request (CSR).
openssl req -new -newkey rsa:4096 -passout pass:"clientpass" -subj "/C=GB/CN=$CERTPREFIX-client-intcatwo-signed" -keyout \
$CERTPREFIX-client-intcatwo-signed.key -sha256 -out $CERTPREFIX-client-intcatwo-signed.csr

# Create THIRD CLIENT cert and sign with INTERMEDIATE TWO cert/key.
openssl x509 -req -passin pass:"intpass" -CA ./$CERTPREFIX-intcatwo.pem -CAkey ./$CERTPREFIX-intcatwo.key -in ./$CERTPREFIX-client-intcatwo-signed.csr \
-out ./$CERTPREFIX-client-intcatwo-signed.pem -extensions v3_ca -CAcreateserial -extfile /certs-config/ca-false.conf

# Sense check what we've just done.
openssl verify -CAfile ./$CERTPREFIX-rootca.pem -untrusted ./$CERTPREFIX-intcaone.pem ./$CERTPREFIX-intcatwo.pem && \
openssl verify -CAfile ./$CERTPREFIX-rootca.pem ./$CERTPREFIX-client-rootsigned.pem && \
openssl verify -CAfile ./$CERTPREFIX-rootca.pem -untrusted ./$CERTPREFIX-intcaone.pem ./$CERTPREFIX-client-intcaone-signed.pem && \
openssl verify -CAfile ./$CERTPREFIX-rootca.pem -untrusted ./$CERTPREFIX-intcaone.pem -untrusted ./$CERTPREFIX-intcatwo.pem ./$CERTPREFIX-client-intcatwo-signed.pem

# Create three more client certs signed by the root, intcaone and intcatwo CAs respectively
# but this time without encrypting the client's private key
openssl req -new -newkey rsa:4096 -nodes -subj "/C=GB/CN=$CERTPREFIX-client-rootsigned-noenc" -keyout \
$CERTPREFIX-client-rootsigned-noenc.key -sha256 -out $CERTPREFIX-client-rootsigned-noenc.csr

openssl x509 -req -passin pass:"rootpass" -CA ./$CERTPREFIX-rootca.pem -CAkey ./$CERTPREFIX-rootca.key -in ./$CERTPREFIX-client-rootsigned-noenc.csr \
-out ./$CERTPREFIX-client-rootsigned-noenc.pem -extensions v3_ca -CAserial $CERTPREFIX-rootca.srl -extfile /certs-config/ca-false.conf

openssl req -new -newkey rsa:4096 -nodes -subj "/C=GB/CN=$CERTPREFIX-client-intcaone-signed-noenc" -keyout \
$CERTPREFIX-client-intcaone-signed-noenc.key -sha256 -out $CERTPREFIX-client-intcaone-signed-noenc.csr

openssl x509 -req -passin pass:"intpass" -CA ./$CERTPREFIX-intcaone.pem -CAkey ./$CERTPREFIX-intcaone.key -in ./$CERTPREFIX-client-intcaone-signed-noenc.csr \
-out ./$CERTPREFIX-client-intcaone-signed-noenc.pem -extensions v3_ca -CAserial $CERTPREFIX-intcaone.srl -extfile /certs-config/ca-false.conf

openssl req -new -newkey rsa:4096 -nodes -subj "/C=GB/CN=$CERTPREFIX-client-intcatwo-signed-noenc" -keyout \
$CERTPREFIX-client-intcatwo-signed-noenc.key -sha256 -out $CERTPREFIX-client-intcatwo-signed-noenc.csr

openssl x509 -req -passin pass:"intpass" -CA ./$CERTPREFIX-intcatwo.pem -CAkey ./$CERTPREFIX-intcatwo.key -in ./$CERTPREFIX-client-intcatwo-signed-noenc.csr \
-out ./$CERTPREFIX-client-intcatwo-signed-noenc.pem -extensions v3_ca -CAserial $CERTPREFIX-intcatwo.srl -extfile /certs-config/ca-false.conf

# Sense check the second trio of client certs
openssl verify -CAfile ./$CERTPREFIX-rootca.pem ./$CERTPREFIX-client-rootsigned-noenc.pem && \
openssl verify -CAfile ./$CERTPREFIX-rootca.pem -untrusted ./$CERTPREFIX-intcaone.pem ./$CERTPREFIX-client-intcaone-signed-noenc.pem && \
openssl verify -CAfile ./$CERTPREFIX-rootca.pem -untrusted ./$CERTPREFIX-intcaone.pem -untrusted ./$CERTPREFIX-intcatwo.pem ./$CERTPREFIX-client-intcatwo-signed-noenc.pem

rm ./*.csr
