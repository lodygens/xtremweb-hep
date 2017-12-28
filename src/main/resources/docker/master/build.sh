#!/bin/sh
#=============================================================================
#
#  File    : build.sh
#  Date    : July 24th, 2017
#  Author  : Oleg Lodygensky
#
#  Change log:
#  - Jul 24th,2017 : Oleg Lodygensky; creation
#
#  OS      : Linux, mac os x
# 
#  Purpose : this script creates and starts a new Docker container for the XWHEP server
#
#=============================================================================


# Copyrights     : CNRS
# Author         : Oleg Lodygensky
# Acknowledgment : XtremWeb-HEP is based on XtremWeb 1.8.0 by inria : http://www.xtremweb.net/
# Web            : http://www.xtremweb-hep.org
# 
#      This file is part of XtremWeb-HEP.
#
#    XtremWeb-HEP is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    XtremWeb-HEP is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with XtremWeb-HEP.  If not, see <http://www.gnu.org/licenses/>.
#
#


THISOS=`uname -s`

case "$THISOS" in
  
  Darwin )
    DATE_FORMAT='+%Y-%m-%d %H:%M:%S%z'
    ;;
  
  Linux )
    DATE_FORMAT='--rfc-3339=seconds'
    ;;
  
  * )
    fatal  "OS not supported ($THISOS)"  TRUE
    ;;
  
esac

#=============================================================================
#
#  Function  fatal (Message, Force)
#
#=============================================================================
fatal ()
{
  msg="$1"
  FORCE="$2"
  [ "$msg" ]  ||  msg="Ctrl+C"
  
  echo  "$(date "$DATE_FORMAT")  $SCRIPTNAME  FATAL : $msg"
  docker kill ${CONTAINERNAME} 
  docker rm   ${CONTAINERNAME} 
  rm -f ${SERVERLOGFILE}
  
  exit 1
}

#=============================================================================
#
#  Function  usage ()
#
#=============================================================================
usage()
{
cat << END_OF_USAGE
  This script create a new container for the XWHEP server.
  This is all created from sources downloaded from github.
  Worker and client Debian packages are copied from the server container.
END_OF_USAGE

  exit 0
}


#=============================================================================
#
#  Main
#
#=============================================================================
trap  fatal  SIGINT  SIGTERM


XWVERSION="11.5.0"
ROOTDIR="$(dirname "$0")"
SCRIPTNAME="$(basename "$0")"

XWJOBUID="$(date '+%Y-%m-%d-%H-%M-%S')"


IMAGENAME="xwhepimg_${XWJOBUID}"
CONTAINERNAME="xwhepcontainer_${XWJOBUID}"
DOCKERFILENAME="Dockerfile"
DOCKERFILE="${ROOTDIR}/Dockerfile"

SERVERLOGFILE="${ROOTDIR}/xwserver_${XWJOBUID}.log"


while [ $# -gt 0 ]; do
  
  case "$1" in
  
    --help )
      usage
      ;;
    
    -v | --verbose | --debug )
      VERBOSE=1
      set -x
      ;;

  esac

  shift

done
 
type docker > /dev/null 2>&1
if [ $? -ne 0 ] ; then
	fatal "docker not installed"
fi

if [ ! -f ${DOCKERFILE} ] ; then
	fatal "${DOCKERFILE} not found"
fi

docker build --force-rm --tag ${IMAGENAME} .
docker run --name ${CONTAINERNAME} ${IMAGENAME} > ${SERVERLOGFILE} 2>&1 &

COUNTER=0
while ( true ) ; do

       grep "INFO : started, listening on port"  ${SERVERLOGFILE} > /dev/null 2>&1
       [ $? -eq 0 ] && break

       COUNTER=$(( COUNTER + 1 ))
       [ ${COUNTER} -gt 12 ] && fatal "There must be something wrong..."

       sleep 10

done


docker cp ${CONTAINERNAME}:/xwhep/xtremweb-hep-master/build/dist/xwhep-${XWVERSION}/xwhep-server-${XWVERSION}.deb ${ROOTDIR}
docker cp ${CONTAINERNAME}:/xwhep/xtremweb-hep-master/build/dist/xwhep-${XWVERSION}/xwhep-server-conf-${XWVERSION}.deb ${ROOTDIR}
docker cp ${CONTAINERNAME}:/xwhep/xtremweb-hep-master/build/dist/xwhep-${XWVERSION}/xwhep-worker-${XWVERSION}.deb ${ROOTDIR}
docker cp ${CONTAINERNAME}:/xwhep/xtremweb-hep-master/build/dist/xwhep-${XWVERSION}/xwhep-client-${XWVERSION}.deb ${ROOTDIR}

docker kill ${CONTAINERNAME} 
docker rm   ${CONTAINERNAME} 
rm -f ${SERVERLOGFILE}

cat << EOF_INFO

  =================
  You can now create and start worker & client containers.
  Please open another terminal and copy :
    - ${ROOTDIR}/xwhep-server-${XWVERSION}.deb to docker/server/ and build the worker container
    - ${ROOTDIR}/xwhep-server-conf-${XWVERSION}.deb to docker/server/ and build the worker container
    - ${ROOTDIR}/xwhep-worker-${XWVERSION}.deb to docker/worker/ and build the worker container
    - ${ROOTDIR}/xwhep-client-${XWVERSION}.deb to docker/client/ and build the client container
  =================

EOF_INFO

echo "Press any key"
read


exit 0
###########################################################
#     EOF        EOF     EOF        EOF     EOF       EOF #
###########################################################
