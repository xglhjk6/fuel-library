#    Copyright 2013 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


class cobbler::checksum_bootpc () {
  case $::operatingsystem {
    /(?i)(centos|redhat)/ : {
      $iptables_save_location = '/etc/sysconfig/iptables'
    }
    /(?i)(debian|ubuntu)/ : {
      $iptables_save_location = '/etc/iptables.rules'
    }
    default: {
      fail('Unsupported OS')
    }
  }

  # TODO(aschultz): replace this with a proper firewall resource usage which
  # requires an firewall module verison bump and figure out how to get around
  # the module not being able to save the rules inside docker (which currently
  # errors)
  exec { 'checksum_fill_bootpc':
    command => "iptables -t mangle -A POSTROUTING -p udp --dport 68 -j CHECKSUM --checksum-fill; iptables-save -c > ${iptables_save_location}", # lint:ignore:80chars
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    unless  => 'iptables -t mangle -S POSTROUTING | grep -q "^-A POSTROUTING -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill"' # lint:ignore:80chars
  }
}
