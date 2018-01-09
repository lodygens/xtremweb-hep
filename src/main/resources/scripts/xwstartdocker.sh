#!/bin/sh
#=============================================================================
#
#  File    : xwstartdocker.sh
#  Date    : November, 2011
#  Author  : Oleg Lodygensky
#
#  Change log:
#  - Jul 3rd,2017 : Oleg Lodygensky; creation
#
#  OS      : Linux, mac os x
# 
#  Purpose : this script creates and starts a new Docker container on worker side
#
# Some environment variables, automatically set by the volunteer resource:
#  - XWJOBUID : this must contain the job UID on worker side
#  - XWSCRATCHPATH : this must contains the directory where drive are stored
#  - XWRAMSIZE : this may contain expected RAM size
#  - XWDISKSPACE : this may contain expected storage capacity
#  - XWPORTS  : this may contain a comma separated ports list
#               ssh  port forwarding localhost:$XWPORTS[0] to guest:22
#               http port forwarding localhost:$XWPORTS[1] to guest:80

# 
#  !!!!!!!!!!!!!!!!    DO NOT EDIT    !!!!!!!!!!!!!!!!
#  Remarks : this script is auto generated by install process
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
  
  [ "$FORCE" = "TRUE" ]  &&  clean
  
  ( [ "$VERBOSE" ]  &&  set -x
    "$VBMGT"  controlvm  "$VMNAME"  poweroff  > /dev/null 2>&1 )
  #
  # Inside 'fatal', the VM state is unknown and possibly inconsistent.
  # So, the above 'poweroff' request does NOT make much sense.
  
  exit 1
}

#=============================================================================
#
#  Function  clean ()
#
#=============================================================================
clean ()
{
  echo
  info_message  "clean '$VMNAME'"
  
  [ "$VERBOSE" ]  &&  echo  > /dev/stderr
  debug_message  "clean :  VMNAME='$VMNAME'"
  [ "$VMNAME" ]  ||  return
  
  LOCKFILE="$LOCKPATH"_"$VMNAME"
  
  wait_for_other_virtualbox_management_to_finish  clean
  info_message  "clean:  Retrieve VirtualBox info"
}

#=============================================================================
#
#  Function  usage ()
#
#=============================================================================
usage()
{
cat << END_OF_USAGE
  This script is an example only to show how to start a Docker container
  on a distributed volunteer resource. 
 
  Some environment variables, automatically set by the volunteer resource:
  - XWJOBUID : this must contain the job UID on worker side
  - XWSCRATCHPATH : this must contains the directory where drive are stored
  - XWRAMSIZE : this may contain expected RAM size
  - XWDISKSPACE : this may contain expected storage capacity
  - XWPORTS  : this may contain a comma separated ports list
               ssh  port forwarding localhost:$XWPORTS[0] to guest:22
               http port forwarding localhost:$XWPORTS[1] to guest:80
  
  If Dockerfile is present, the image is built like this:
  $ docker build --force-rm --tag $XWJOBUID .
  
END_OF_USAGE

  exit 0
}


#=============================================================================
#
#  Main
#
#=============================================================================
trap  fatal  SIGINT  SIGTERM



ROOTDIR="$(dirname "$0")"
SCRIPTNAME="$(basename "$0")"

if [ "${SCRIPTNAME#*.sh}" ]; then
  SCRIPTNAME=xwstartvm.sh
  VERBOSE=TRUE
  TESTINGONLY=''                         # Worker, so debug is NOT possible
else
  VERBOSE=''
  TESTINGONLY=TRUE                       # Local machine, so debug is possible
fi

if [ "$TESTINGONLY" = "TRUE" ] ; then
  XWJOBUID="$(date '+%Y-%m-%d-%H-%M-%S')"
  XWSCRATCHPATH="$(dirname "$0")"
  SAVDIR=`pwd`
  cd "$XWSCRATCHPATH"
  XWSCRATCHPATH=`pwd`
  cd "$SAVDIR"
  XWCPULOAD=100
else
  [ -z "$XWJOBUID" ] && fatal "XWJOBUID is not set"
fi


IMAGENAME="xwimg_${XWJOBUID}"
CONTAINERNAME="xwcontainer_${XWJOBUID}"
DOCKERFILENAME="Dockerfile"


while [ $# -gt 0 ]; do
  
  case "$1" in
  
    --help )
      usage
      ;;
    
    -v | --verbose | --debug )
      VERBOSE=1
      set -x
      ;;

    -i | --img | --imgname )
      shift
      IMAGENAME="$1"
      ;;
  esac

  shift

done
 

if [ -f ${DOCKERFILENAME} ] ; then
    docker build --force-rm --tag ${IMAGENAME} .
fi

docker run -v $(pwd):/host --rm --name ${CONTAINERNAME} ${IMAGENAME} ${ARGS}

# clean everything
if [ "$TESTINGONLY" != "TRUE" ] ; then
  docker stop ${CONTAINERNAME} &&docker rm ${CONTAINERNAME} && docker rmi ${IMAGENAME}
fi


exit 0
###########################################################
#     EOF        EOF     EOF        EOF     EOF       EOF #
###########################################################
