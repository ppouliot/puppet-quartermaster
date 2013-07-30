#!/usr/bin/python
"""
This script is used to generate a SHA1 Hash
"""
import sys 
import hashlib
# Uncomment to Prompt for Password rather than apply at 
#password = raw_input('Please enter the string to be hashed:')

import argparse

parser = argparse.ArgumentParser(
    prog='make_hash',
    prefix_chars='-'
)

#parser.add_argument('password')
parser.add_argument('-P','--password', type=str, help="Supply the Password String to Hash")
parser.add_argument('-v','--verbose', action="store_true", help="Print additional output")
parser.add_argument('-S','--SHA1', action="store_true", help="Create a SHA1 Hash")
parser.add_argument('-M','--MD5', action="store_true", help="Create a MD5 Hash")

args = parser.parse_args()

create_Sha1 = hashlib.sha1(args.password)
sha1_password = create_Sha1.hexdigest()

create_Md5 = hashlib.md5(args.password)
md5_password = create_Md5.hexdigest()

if args.verbose:
  if args.SHA1:
    print "String Entered:", args.password
    print "SHA1 Digest:", sha1_password
    print "SHA1 Digenst Length:", len(sha1_password)
  if args.MD5:
    print "String Entered:", args.password
    print "MD5 Digest:", md5_password
    print "MD5 Digenst Length:", len(md5_password)
  
  
else: 
  if args.SHA1:
   print sha1_password
  if args.MD5:
   print md5_password

