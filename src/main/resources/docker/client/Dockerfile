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
LABEL description="This creates a Docker image for the XWHEP client"

EXPOSE 4327

ENV XWVERSION "11.5.0"


RUN apt-get update
#RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y openjdk-8-jre zip unzip vim iputils-ping
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y openjdk-8-jre zip unzip vim

ADD . /xwhep
WORKDIR /xwhep
RUN dpkg -i xwhep-client-$XWVERSION.deb

#
# A script to set server address
# 
RUN echo "#!/bin/sh" > /usr/bin/xwsetserveraddr.sh
RUN echo "if [ ! -z \$XWSERVERADDR ] ; then " >> /usr/bin/xwsetserveraddr.sh
RUN echo "   sed \"s/127\\.0\\.0\\.1.*localhost/127\\.0\\.0\\.1 localhost $HOSTNAME/g\" /etc/hosts" >> /usr/bin/xwsetserveraddr.sh
RUN echo "   echo \"\$XWSERVERADDR xwserver\" >> /etc/hosts" >> /usr/bin/xwsetserveraddr.sh
RUN echo "fi" >> /usr/bin/xwsetserveraddr.sh
RUN chmod +x /usr/bin/xwsetserveraddr.sh
