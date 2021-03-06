require 'spec_helper'

describe 'haproxy::listen' do
  let(:pre_condition) { 'include haproxy' }
  let(:title) { 'tyler' }
  let(:facts) do
    {
      :ipaddress      => '1.1.1.1',
      :osfamily       => 'Redhat',
      :concat_basedir => '/dne',
    }
  end
  context "when only one port is provided" do
    let(:params) do
      {
        :name  => 'croy',
        :ipaddress => '1.1.1.1',
        :ports => '18140'
      }
    end

    it { should contain_concat__fragment('croy_listen_block').with(
      'order'   => '20-croy-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten croy\n  bind 1.1.1.1:18140 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  # C9940
  context "when an array of ports is provided" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '23.23.23.23',
        :ports     => [
          '80',
          '443',
        ]
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind 23.23.23.23:80 \n  bind 23.23.23.23:443 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  # C9940
  context "when a comma-separated list of ports is provided" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '23.23.23.23',
        :ports     => '80,443'
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind 23.23.23.23:80 \n  bind 23.23.23.23:443 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  # C9962
  context "when empty list of ports is provided" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '23.23.23.23',
        :ports     => [],
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  # C9963
  context "when a port is provided greater than 65535" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '23.23.23.23',
        :ports     => '80443'
      }
    end

    it 'should raise error' do
      expect { catalogue }.to raise_error Puppet::Error, /outside of range/
    end
  end
  # C9974
  context "when an invalid ipv4 address is passed" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '2323.23.23',
        :ports     => '80'
      }
    end

    it 'should raise error' do
      expect { catalogue }.to raise_error Puppet::Error, /Invalid IP address/
    end
  end
  # C9977
  context "when a valid hostname is passed" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => 'some-hostname',
        :ports     => '80'
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind some-hostname:80 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  context "when a * is passed for ip address" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '*',
        :ports     => '80'
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind *:80 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  context "when a bind parameter hash is passed" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '',
        :bind      => {'10.0.0.1:333' => ['ssl', 'crt', 'public.puppetlabs.com'], '192.168.122.1:8082' => []},
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind 10.0.0.1:333 ssl crt public.puppetlabs.com\n  bind 192.168.122.1:8082 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  context "when a ports parameter and a bind parameter are passed" do
    let(:params) do
      {
        :name  => 'apache',
        :bind  => {'192.168.0.1:80' => ['ssl']},
        :ports => '80'
      }
    end

    it 'should raise error' do
      expect { catalogue }.to raise_error Puppet::Error, /mutually exclusive/
    end
  end
  # C9977
  context "when an invalid hostname is passed" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => '$some_hostname',
        :ports     => '80'
      }
    end

    it 'should raise error' do
      expect { catalogue }.to raise_error Puppet::Error, /Invalid IP address/
    end
  end
  # C9974
  context "when an invalid ipv6 address is passed" do
    let(:params) do
      {
        :name      => 'apache',
        :ipaddress => ':::6',
        :ports     => '80'
      }
    end

    it 'should raise error' do
      expect { catalogue }.to raise_error Puppet::Error, /Invalid IP address/
    end
  end
  context "when bind options are provided" do
    let(:params) do
      {
        :name         => 'apache',
        :ipaddress    => '1.1.1.1',
        :ports        => '80',
        :bind_options => [ 'the options', 'go here' ]
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind 1.1.1.1:80 the options go here\n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end
  context "when bind parameter is used without ipaddress parameter" do
    let(:params) do
      {
        :name => 'apache',
        :bind => { '1.1.1.1:80' => [] },
      }
    end

    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind 1.1.1.1:80 \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end

  context "when bind parameter is used with more complex address constructs" do
    let(:params) do
      {
        :name  => 'apache',
        :bind  => {
          '1.1.1.1:80'                 => [],
          ':443,:8443'                 => [ 'ssl', 'crt public.puppetlabs.com', 'no-sslv3' ],
          '2.2.2.2:8000-8010'          => [ 'ssl', 'crt public.puppetlabs.com' ],
          'fd@${FD_APP1}'              => [],
          '/var/run/ssl-frontend.sock' => [ 'user root', 'mode 600', 'accept-proxy' ]
        },
      }
    end
    it { should contain_concat__fragment('apache_listen_block').with(
      'order'   => '20-apache-00',
      'target'  => '/etc/haproxy/haproxy.conf',
      'content' => "\nlisten apache\n  bind /var/run/ssl-frontend.sock user root mode 600 accept-proxy\n  bind 1.1.1.1:80 \n  bind 2.2.2.2:8000-8010 ssl crt public.puppetlabs.com\n  bind :443,:8443 ssl crt public.puppetlabs.com no-sslv3\n  bind fd@${FD_APP1} \n  balance  roundrobin\n  option  tcplog\n  option  ssl-hello-chk\n"
    ) }
  end

end
