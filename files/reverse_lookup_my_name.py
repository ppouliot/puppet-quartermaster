#!/usr/bin/python
import sys
import socket
import argparse

parser = argparse.ArgumentParser(
    prog='find_my_name',
    prefix_chars='-'
)

parser.add_argument('-I','--ipaddress', type=str, help="The IP Address to reverse resolve")
parser.add_argument('-v','--verbose', action="store_true", help="Print additional output")

args = parser.parse_args()

# ReverseLookup
reverse_lookup = socket.gethostbyaddr(args.ipaddress)
fqdn_only = socket.getfqdn(args.ipaddress)

fqdn,aliases,net_ip = socket.gethostbyaddr(args.ipaddress)



#if args.verbose:
if args.ipaddress:
  print "IPADDRESS Entered: ", args.ipaddress
  print "REVERSE Lookup Results"
  print "FQDN: ", fqdn 
  print "ALIASES: ", aliases
  print "Network IP: ", net_ip
  print "FQDN_ONLY: ", fqdn_only 

