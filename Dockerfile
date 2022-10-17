FROM ubuntu:20.04

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg openssl sudo

RUN apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists

RUN mkdir /certs-config
RUN mkdir /out

WORKDIR /certs-config

# Config file for intermediate cert
RUN echo \
'[v3_ca]\n\
basicConstraints = CA:TRUE\n'\
>> ca-true.conf

# Config file for client/device cert
RUN echo \
'[v3_ca]\n\
basicConstraints = CA:FALSE\n'\
>> ca-false.conf

COPY scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-certs.sh /usr/local/bin/set-owner.sh

ENV USERID=1000
ENV GROUPID=1000

WORKDIR /out

CMD ["/bin/bash"]
