#!/bin/bash
# NAME:
#   CSV2JSON.sh
#
# DESC:
#  Example script on how to convert a .CSV file to a .JSON file. The
#  code has been tested on Oracle Linux, expected to run on other
#  Linux distributions as well.
#
# LOG:
# VERSION---DATE--------NAME-------------COMMENT
# 0.1       11DEC2016   Johan Louwers    Initial upload to github.com
#
# LICENSE:
# Copyright (C) 2016  Johan Louwers
#
# This code is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this code; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
# *
# */

 inputFile=/tmp/example.csv
 OLDIFS=$IFS


 IFS=,
  [ ! -f $inputFile ] && { echo "$inputFile file not found"; exit 99; }

# writing the "header" section of the JSON file to ensure we have a
# good start and the JSON file will be able to work with multiple
# lines from the CSV file in a JSON array.
 echo "
  {
   \"checklog\":
   ["

# ensuring we have the number of lines from the input file as we
# have to ensure that the last part of the array is closed in a
# manner that no more information will follow. (not closing the
# the section with "}," however closing with "}" instead to
# prevent incorrect JSON formats. We will use a if check in the
# loop later to ensure this is written correctly.
 csvLength=`cat $inputFile | wc -l`
 csvDepth=1

 while read cardid checkstatus checkdate checktime doordirection doorstatus doorid
  do
     echo -e "   {
      \"CARDCHECK\" :
       {
        \"CARDID\" : \"$cardid\",
        \"CHECKSTATUS\" : \"$checkstatus\",
        \"CHECKDATE\" : \"$checkdate\",
        \"CHECKTIME\" : \"$checktime\",
        \"DIRECTION\" : \"$doordirection\",
        \"DOORSTATUS\" : \"$doorstatus\",
        \"DOORID\" : \"$doorid\"
       }"
     if [ "$csvDepth" -lt "$csvLength" ];
      then
        echo -e "     },"
      else
        echo -e "     }"
     fi
   csvDepth=$(($csvDepth+1))
  done < $inputFile

# writing the "footer" section of the JSON file to ensure we do
# close the JSON file properly and in accordance to the required
# JSON formating.
 echo "   ]
  }"

 IFS=$OLDIFS
