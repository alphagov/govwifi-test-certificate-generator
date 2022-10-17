# GovWifi Test Certificate Generator

This repo can be used to generate sets of certificates with consistent relationships for local testing
of FreeRADIUS configurations.

## How to generate certificates

To generate a set of certificates run:

```
make generate
```

It's often useful to be able to create two or more unrelated chains of certificates. To prefix the name of each certificate in a set, and the 'CN' field in each certificate's subject field, run:

```
CERTPREFIX=myprefix make generate
```

Notes:
- Each set of certs is created in a new directory named `certs-out-YYYY-MM-DD-HH-MM-SS`
- If no prefix is provided the word 'test' is used.

## The generated certificates

Assuming the default prefix 'test' is used, the following will be produced:

```

test-rootca.pem
 |
 |------------------------test-client-rootsigned.pem
 |                     |
 |                     |--test-client-rootsigned-noenc.pem
 |
test-intcaone.pem
 |
 |------------------------test-client-intcaone-signed.pem
 |                     |
 |                     |--test-client-intcaone-signed-noenc.pem
 |
test-intcatwo.pem
 |
 |------------------------test-client-intcatwo-signed.pem
                       |
                       |--test-client-intcatwo-signed-noenc.pem

```

Notes:
- Each `.pem` file has a counterpart `.key` file with the same name
- The `*-rootca.pem` is self-signed
- The client certificates each have `CA:FALSE` set in their extensions. All others have `CA:TRUE`
- The client certificates named `*-noenc.pem` each have an unencrypted private key
- The passphrase for the root cert's private key (`*-rootca.key`) is 'rootpass`
- The passphrase for *all* of the intermediate certs' private keys (`*-intcaone.key`, `*-intcatwo.key`) is 'intpass'
- For those client certs with encrypted private keys (`*-client-*signed.pem`), the password is always 'clientpass'


## Working with an existing set of certificates

If you have generated a set of certs and would like to work them from within a container, run the following:

```
BINDNAME=certs-out-YYYY-MM-DD-HH-MM-SS

docker run --rm -it -v=$(pwd)/$BINDNAME:/out -e USERID=$(id -u) -e GROUPID=$(id -g) govwifi-test-certs sh -c 'init.sh && /bin/bash'
```

## Examining certificates

Whether in a container or running on the host, to see the details of a certificate run (e.g.):

```
openssl x509 -in ./certs-out-YYYY-MM-DD-HH-MM-SS/test-client-rootsigned.pem -text -noout
```
