#!/bin/bash
# NAME:
#   password_force.sh
#
# DESC:
#   Fully working script snippet, orginally part of a wider first boot
#   script. Used for enforcing root to reset password at next login
#   and to ensure the password policy is enforced on the machine.
#
# LOG:
# VERSION---DATE--------NAME-------------COMMENT
# 0.1       22DEC15   Johan Louwers    Initial upload to github.com
#
# LICENSE:
# Copyright (C) 2015  Johan Louwers
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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# *
# */



# function used to enfore root to reset password on next login.
 function forceRootPwd {
    logger "Setting enforced root password change"
    chage -d 0 root
 }



# function used to ensure the password policy is set
 function forcePolicy {
    logger "setting the password policy"
    echo "password    required    pam_pwquality.so retry=3" >> /etc/pam.d/passwd
    echo "minlen = 8" >> /etc/security/pwquality.conf
    echo "minclass = 4" >> /etc/security/pwquality.conf
    echo "maxsequence = 3" >> /etc/security/pwquality.conf
    echo "maxrepeat = 3" >> /etc/security/pwquality.conf
 }



# call the required functions
 forceRootPwd
 forcePolicy
