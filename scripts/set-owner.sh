#!/bin/bash

addgroup --gid $GROUPID hostgroup
adduser --no-create-home --disabled-password --gecos "" --uid $USERID --gid $GROUPID hostuser
chown -R $USERID:$GROUPID /out
