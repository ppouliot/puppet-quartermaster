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
parser.add_argument('-S256','--SHA256', action="store_true", help="Create a SHA256 Hash")
parser.add_argument('-S512','--SHA512', action="store_true", help="Create a SHA512 Hash")
parser.add_argument('-M','--MD5', action="store_true", help="Create a MD5 Hash")
parser.add_argument('-A','--all', action="store_true", help="Create All Available Hashes")

args = parser.parse_args()
# SHA512
create_Sha512 = hashlib.sha512(args.password)
sha512_password = create_Sha512.hexdigest()

# SHA256
create_Sha256 = hashlib.sha256(args.password)
sha256_password = create_Sha256.hexdigest()

# SHA1
create_Sha1 = hashlib.sha1(args.password)
sha1_password = create_Sha1.hexdigest()

#MD5
create_Md5 = hashlib.md5(args.password)
md5_password = create_Md5.hexdigest()

if args.verbose:
  if args.SHA512:
    print "String Entered:", args.password
    print "SHA512 Digest:", sha512_password
    print "SHA512 Digest Length:", len(sha512_password)
  if args.SHA256:
    print "String Entered:", args.password
    print "SHA256 Digest:", sha256_password
    print "SHA256 Digent Length:", len(sha256_password)
  if args.SHA1:
    print "String Entered:", args.password
    print "SHA1 Digest:", sha1_password
    print "SHA1 Digest Length:", len(sha1_password)
  if args.MD5:
    print "String Entered:", args.password
    print "MD5 Digest:", md5_password
    print "MD5 Digest Length:", len(md5_password)
  if args.all:
    print "String Entered:", args.password
    print "SHA512 Digest:", sha512_password
    print "SHA512 Digest Length:", len(sha512_password)
    print "SHA256 Digest:", sha256_password
    print "SHA256 Digest Length:", len(sha256_password)
    print "SHA1 Digest:", sha1_password
    print "SHA1 Digest Length:", len(sha1_password)
    print "MD5 Digest:", md5_password
    print "MD5 Digest Length:", len(md5_password)
  
  
else: 
  if args.SHA512:
    print sha512_password
  if args.SHA256:
    print sha256_password
  if args.SHA1:
    print sha1_password
  if args.MD5:
    print md5_password
  if args.all:
    print "-----------------"
    print "String Entered:", args.password
    print "-----------------"
    print "SHA512 Digest:", sha512_password
    print "SHA512 Digest Length:", len(sha512_password)
    print "-------------------------"
    print "SHA256 Digest:", sha256_password
    print "SHA256 Digest Length:", len(sha256_password)
    print "------------------------"
    print "SHA1 Digest:", sha1_password
    print "SHA1 Digest Length:", len(sha1_password)
    print "----------------------"
    print "MD5 Digest:", md5_password
    print "MD5 Digest Length:", len(md5_password)
    print "---------------------"

