#!/bin/sh
ACTIVE_INTERFACE=`/usr/bin/ip route get 1 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f5`
NEWHOSTNAME=`/usr/bin/ifconfig $ACTIVE_INTERFACE | /usr/bin/grep "ether" | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f3 | /usr/bin/sed -e "s/://g;"`
echo $ACTIVE_INTERFACE
echo $NEWHOSTNAME
sudo hostname -s $NEWHOSTNAME
sudo hostnamectl set-hostname $NEWHOSTNAME

workdir=$(mktemp --directory)
trap "rm --force --recursive ${workdir}" SIGINT SIGTERM EXIT

cat >"${workdir}/cloud-config.yml" <<EOF


#cloud-config

coreos:
  etcd2:
    # generate a new token for each unique cluster from https://discovery.etcd.io/new?size=3
    # discovery: "https://discovery.etcd.io/<token>"
    discovery: "https://discovery.etcd.io/cc697139b119bbb7f51d03cd9564ca8b"
    # multi-region and multi-cloud deployments need to use ${COREOS_PUBLIC_IPV4}
    advertise-client-urls: "http://${COREOS_PUBLIC_IPV4}:2379"
    initial-advertise-peer-urls: "http://${COREOS_PRIVATE_IPV4}:2380"
    # listen on both the official ports and the legacy ports
    # legacy ports can be omitted if your application doesn't depend on them
    listen-client-urls: "http://0.0.0.0:2379,http://0.0.0.0:4001"
    listen-peer-urls: "http://${COREOS_PRIVATE_IPV4}:2380,http://${COREOS_PRIVATE_IPV4}:7001"



  fleet:
    public-ip: ${COREOS_PUBLIC_IPV4}
  # uncomment for azure.
  # metadata: region=us-east

  units:
    - name: "etcd2.service"
      command: "start"

    - name: "fleet.service"
      command: "start"

    - name: "docker-tcp.socket"
      command: "start"
      content: |
        [Unit]
        Description=Docker Socket for the API
        [Socket]
        ListenStream=2375
        Service=docker.service
        BindIPv6Only=both
        [Install]
        WantedBy=sockets.target

ssh_authorized_keys:
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlZLcFVYcMbYkJ+pwSsTnfOfwmOLZe26J6PBHa/17ZuzBI563BWJfTybjgphVOJwQKAqN+cBfzHZ66PaQm0vqx2Efee1uGq/vd8cmAIyEqmZUnbkxPRQ3G7YLlAwqZalRo2TEglWhEK+O+7hycV3NhCKYpG/2DZwGbW97bKh01R3R0pt9PiSi570w4W4oeUxPioqR/dIJf+g4EnOCnPMvLAT6exGI9hcKCRH3604Qnh2z5rQ0aG4PYS8uCi5MS8AevuWxNg7OKE6e59XxDvruULq+4jerAls+HZVomZ2AQvbcabpqKFEKvVtE12k5uzAWelmZU49NCIHuUgrX5hm0X peter@hackintosh.local"
  - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKetw3EOkjAc3+QuDbumo1GovGzCZbQ7McDDFPyis779 peter@quartermaster"
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq1k6++HIrouWWMw/TevD4SaPcMoOHl5rNqGNZ5FghSJb8F7A7DiDhnU8MW8x5pClrQQyY6KTKUI7p1PZptuiNbhf7c2T0O+Rxf0PB0Pt8qZ5RK65rJOXBhPaYt7VBMM18fOrdojoj4kchdRfEYRny4xy3uj3qNwzUSdxRYWDi/q6IGl5wJjVN6O/cvSz/V6hVTi+Hcm+Luch1ZiWlXefuUbIwvBvgazCBx7fPeh4l1DBFtzAec3MUKY73PTcuHfvv/6Nwy4NtRRZAA45Mk6aGDoo1lMeJZUoyKw7ev6XRt9g30s7uqDNDXaieOJlhDCXdOo5cC9Sc4flLFtjk/UsZqjxNl5UALxIw4ZrZ1A/byKZ5gXQ3b6vTR17eu5dhZTClnGIgZZ3R4DNuaNUozlJwoviC8MHe8NIu6H6VseN70MMQX/xdYqDWM45AYo00N3kslndVvoWVGbVlc+0qSisKkJ1Q1ceMmPmsJBvUlcvI5WYFu0wncj1J2sV5uQIzzlGDb/WjthCXN8I+NS29xMi6hDewYrP9Z8+nrDHPpuMCEeQb6tT8fZbytVNRrravetzdqnFFX7qpIkY7UjfHVeDG53l2yknyJJOGr2QPuDwaQvEHmdlb1O2MHTOMFHnNhDQs3Tj8Nvl0BNZmB2N8RcyFny6x3C2+9VhkXAzvn+kitQ== hyper-v_ci@microsoft.com"

hostname: $NEWHOSTNAME
#( test -d /home/jenkins/java || (mkdir /home/jenkins/java && curl -s -L https://javadl.oracle.com/webapps/download/AutoDL?BundleId=83376 | tar -C /home/jenkins/java --strip=1 -zx) && ssh-keyscan -H github.com > /home/jenkins/.ssh/known_hosts ) ;

users:
  - name: "core"
#   password_hash: <%= @distro %>
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlZLcFVYcMbYkJ+pwSsTnfOfwmOLZe26J6PBHa/17ZuzBI563BWJfTybjgphVOJwQKAqN+cBfzHZ66PaQm0vqx2Efee1uGq/vd8cmAIyEqmZUnbkxPRQ3G7YLlAwqZalRo2TEglWhEK+O+7hycV3NhCKYpG/2DZwGbW97bKh01R3R0pt9PiSi570w4W4oeUxPioqR/dIJf+g4EnOCnPMvLAT6exGI9hcKCRH3604Qnh2z5rQ0aG4PYS8uCi5MS8AevuWxNg7OKE6e59XxDvruULq+4jerAls+HZVomZ2AQvbcabpqKFEKvVtE12k5uzAWelmZU49NCIHuUgrX5hm0X peter@hackintosh.local"
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKetw3EOkjAc3+QuDbumo1GovGzCZbQ7McDDFPyis779 peter@quartermaster"
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq1k6++HIrouWWMw/TevD4SaPcMoOHl5rNqGNZ5FghSJb8F7A7DiDhnU8MW8x5pClrQQyY6KTKUI7p1PZptuiNbhf7c2T0O+Rxf0PB0Pt8qZ5RK65rJOXBhPaYt7VBMM18fOrdojoj4kchdRfEYRny4xy3uj3qNwzUSdxRYWDi/q6IGl5wJjVN6O/cvSz/V6hVTi+Hcm+Luch1ZiWlXefuUbIwvBvgazCBx7fPeh4l1DBFtzAec3MUKY73PTcuHfvv/6Nwy4NtRRZAA45Mk6aGDoo1lMeJZUoyKw7ev6XRt9g30s7uqDNDXaieOJlhDCXdOo5cC9Sc4flLFtjk/UsZqjxNl5UALxIw4ZrZ1A/byKZ5gXQ3b6vTR17eu5dhZTClnGIgZZ3R4DNuaNUozlJwoviC8MHe8NIu6H6VseN70MMQX/xdYqDWM45AYo00N3kslndVvoWVGbVlc+0qSisKkJ1Q1ceMmPmsJBvUlcvI5WYFu0wncj1J2sV5uQIzzlGDb/WjthCXN8I+NS29xMi6hDewYrP9Z8+nrDHPpuMCEeQb6tT8fZbytVNRrravetzdqnFFX7qpIkY7UjfHVeDG53l2yknyJJOGr2QPuDwaQvEHmdlb1O2MHTOMFHnNhDQs3Tj8Nvl0BNZmB2N8RcyFny6x3C2+9VhkXAzvn+kitQ== hyper-v_ci@microsoft.com"
  - name: "jenkins"
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq1k6++HIrouWWMw/TevD4SaPcMoOHl5rNqGNZ5FghSJb8F7A7DiDhnU8MW8x5pClrQQyY6KTKUI7p1PZptuiNbhf7c2T0O+Rxf0PB0Pt8qZ5RK65rJOXBhPaYt7VBMM18fOrdojoj4kchdRfEYRny4xy3uj3qNwzUSdxRYWDi/q6IGl5wJjVN6O/cvSz/V6hVTi+Hcm+Luch1ZiWlXefuUbIwvBvgazCBx7fPeh4l1DBFtzAec3MUKY73PTcuHfvv/6Nwy4NtRRZAA45Mk6aGDoo1lMeJZUoyKw7ev6XRt9g30s7uqDNDXaieOJlhDCXdOo5cC9Sc4flLFtjk/UsZqjxNl5UALxIw4ZrZ1A/byKZ5gXQ3b6vTR17eu5dhZTClnGIgZZ3R4DNuaNUozlJwoviC8MHe8NIu6H6VseN70MMQX/xdYqDWM45AYo00N3kslndVvoWVGbVlc+0qSisKkJ1Q1ceMmPmsJBvUlcvI5WYFu0wncj1J2sV5uQIzzlGDb/WjthCXN8I+NS29xMi6hDewYrP9Z8+nrDHPpuMCEeQb6tT8fZbytVNRrravetzdqnFFX7qpIkY7UjfHVeDG53l2yknyJJOGr2QPuDwaQvEHmdlb1O2MHTOMFHnNhDQs3Tj8Nvl0BNZmB2N8RcyFny6x3C2+9VhkXAzvn+kitQ== hyper-v_ci@microsoft.com"
  - name: "git"
    ssh_authorized_keys:
      - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq1k6++HIrouWWMw/TevD4SaPcMoOHl5rNqGNZ5FghSJb8F7A7DiDhnU8MW8x5pClrQQyY6KTKUI7p1PZptuiNbhf7c2T0O+Rxf0PB0Pt8qZ5RK65rJOXBhPaYt7VBMM18fOrdojoj4kchdRfEYRny4xy3uj3qNwzUSdxRYWDi/q6IGl5wJjVN6O/cvSz/V6hVTi+Hcm+Luch1ZiWlXefuUbIwvBvgazCBx7fPeh4l1DBFtzAec3MUKY73PTcuHfvv/6Nwy4NtRRZAA45Mk6aGDoo1lMeJZUoyKw7ev6XRt9g30s7uqDNDXaieOJlhDCXdOo5cC9Sc4flLFtjk/UsZqjxNl5UALxIw4ZrZ1A/byKZ5gXQ3b6vTR17eu5dhZTClnGIgZZ3R4DNuaNUozlJwoviC8MHe8NIu6H6VseN70MMQX/xdYqDWM45AYo00N3kslndVvoWVGbVlc+0qSisKkJ1Q1ceMmPmsJBvUlcvI5WYFu0wncj1J2sV5uQIzzlGDb/WjthCXN8I+NS29xMi6hDewYrP9Z8+nrDHPpuMCEeQb6tT8fZbytVNRrravetzdqnFFX7qpIkY7UjfHVeDG53l2yknyJJOGr2QPuDwaQvEHmdlb1O2MHTOMFHnNhDQs3Tj8Nvl0BNZmB2N8RcyFny6x3C2+9VhkXAzvn+kitQ== hyper-v_ci@microsoft.com"

EOF

#get_ipv4() {
#    IFACE="${1}"
#
#    local ip
#    while [ -z "${ip}" ]; do
#        ip=$(ip -4 -o addr show dev "${IFACE}" scope global | gawk '{split ($4, out, "/"); print out[1]}')
#        sleep .1
#    done

#    echo "${ip}"
#}

#export COREOS_PUBLIC_IPV4=$(get_ipv4 eth0)
#export COREOS_PRIVATE_IPV4=$(get_ipv4 eth1)

if [ -e "/dev/vda" ]
then
  for v_partition in $(sudo parted -s /dev/vda print|awk '/^ / {print $1}')
  do
    sudo parted -s /dev/vda rm ${v_partition}
  done
 # Zero MBR
  sudo dd if=/dev/zero of=/dev/vda bs=512 count=1
  sudo coreos-install -d /dev/vda -C <%= @release %> -c <%= @name %>.<%= @autofile %>
fi


if [ -e "/dev/sda" ]
then
  for partition in $(sudo parted -s /dev/sda print|awk '/^ / {print $1}')
  do
    sudo parted -s /dev/sda rm ${partition}
  done
  # Zero MBR
  sudo dd if=/dev/zero of=/dev/sda bs=512 count=1
  sudo coreos-install -d /dev/sda -C <%= @release %> -c <%= @name %>.<%= @autofile %>
fi

# Reboot
sudo reboot

