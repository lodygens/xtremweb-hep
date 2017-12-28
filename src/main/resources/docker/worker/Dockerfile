#
#  Copyrights     : CNRS
#  Author         : Oleg Lodygensky
#  Acknowledgment : XtremWeb-HEP is based on XtremWeb 1.8.0 by inria : http://www.xtremweb.net/
#  Web            : http://www.xtremweb-hep.org
#   
#  This file is part of XtremWeb-HEP.
# 
#  XtremWeb-HEP is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  XtremWeb-HEP is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with XtremWeb-HEP.  If not, see <http://www.gnu.org/licenses/>.
#
#

# Versionning
#  July 24th, 2017
#  0.3
#    - xwversion : 10.6.0
#    - using ADD and WORKDIR to ease usage
#    - reducing packages list to the necessary only to reduce image size
#

FROM ubuntu:16.04
MAINTAINER Oleg Lodygensky (oleg.lodygensky@lal.in2p3.fr)
LABEL "copyrights"="CNRS 2016"
LABEL "author"="Oleg Lodygensky"
LABEL version="0.3"
LABEL description="This creates a Docker image for the XWHEP worker"
EXPOSE 4324 443

ENV XWVERSION "11.5.0"


#
# DEBIAN_FRONTEND=noninteractive bypasses user input.
# Hence, mysql-server installation will not ask
# for the new mysql admin password;
# and mysql admin password will be empty
#
#RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y apt-utils
#RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y openjdk-8-jre zip unzip wget make ant gcc uuid uuid-runtime vim git
RUN apt-get update
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y openjdk-8-jre zip unzip

#COPY xwhep-worker-$XWVERSION.deb /tmp/

ADD . /xwhep
WORKDIR /xwhep

RUN dpkg -i xwhep-worker-$XWVERSION.deb

RUN sed -i "s/^V_NICE=.*//g" /opt/xwhep-worker-$XWVERSION/bin/xtremwebconf.sh
RUN sed -i "s/LAUNCHER.*//g" /opt/xwhep-worker-$XWVERSION/conf/xtremweb.worker.conf
RUN sed -i "s/DISPATCHERS.*/DISPATCHERS=xwserver/g" /opt/xwhep-worker-$XWVERSION/conf/xtremweb.worker.conf

#
# Entry point script
# 
RUN echo "#!/bin/sh" > /tmp/xwstart.sh
RUN echo "if [ ! -z \$XWSERVERADDR ] ; then " >> /tmp/xwstart.sh
RUN echo "   sed \"s/127\\.0\\.0\\.1.*localhost/127\\.0\\.0\\.1 localhost $HOSTNAME/g\" /etc/hosts" >> /tmp/xwstart.sh
RUN echo "   echo \"\$XWSERVERADDR xwserver\" >> /etc/hosts" >> /tmp/xwstart.sh
RUN echo "fi" >> /tmp/xwstart.sh
RUN echo "cat /etc/hosts" >> /tmp/xwstart.sh
RUN echo "/etc/init.d/xtremweb.worker console" >> /tmp/xwstart.sh
RUN chmod +x /tmp/xwstart.sh

ENTRYPOINT [ "/tmp/xwstart.sh" ]
