#!/bin/sh
puppet parser validate site.pp
OUT=$?
if [ $OUT -eq 0 ];then
   echo "Puppet manifest OK!"
fi