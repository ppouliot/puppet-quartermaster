#!/bin/sh

workdir=$(mktemp --directory)
trap "rm --force --recursive ${workdir}" SIGINT SIGTERM EXIT

cat >"${workdir}/cloud-config.yml" <<EOF
#cloud-config
coreos:
  etcd:
    discovery: 
    addr: \\$public_ipv4:4001
    peer-addr: \\$private_ipv4:7001
  units:
    - name: etcd.service
      command: start
    - name: fleet.service
      command: start
EOF

get_ipv4() {
    IFACE="${1}"

    local ip
    while [ -z "${ip}" ]; do
        ip=$(ip -4 -o addr show dev "${IFACE}" scope global | gawk '{split ($4, out, "/"); print out[1]}')
        sleep .1
    done

    echo "${ip}"
}

export COREOS_PUBLIC_IPV4=$(get_ipv4 eth0)
export COREOS_PRIVATE_IPV4=$(get_ipv4 eth1)

coreos-cloudinit --from-file="${workdir}/cloud-config.yml"
