require 'spec_helper'
require 'shared-examples'
manifest = 'swift/keystone.pp'

describe manifest do
  shared_examples 'catalog' do
    it 'should set empty trusts_delegated_roles for swift auth' do
      contain_class('swift::keystone::auth')
    end

    swift                = Noop.hiera_structure('swift')

    if swift['management_vip']
      management_vip     = swift['management_vip']
    else
      management_vip     = Noop.hiera('management_vip')
    end

    if Noop.hiera_structure('use_ssl/swift_public', false)
      public_protocol = 'https'
      public_address  = Noop.hiera_structure('use_ssl/swift_public_hostname')
    elsif Noop.hiera_structure('public_ssl/services')
      public_address  = Noop.hiera_structure('public_ssl/hostname')
      public_protocol = 'https'
    elsif swift['public_vip']
      public_protocol = 'http'
      public_address  = swift['public_vip']
    else
      public_address  = Noop.hiera('public_vip')
      public_protocol = 'http'
    end

    if Noop.hiera_structure('use_ssl/swift_internal', false)
      internal_protocol = 'https'
      internal_address  = Noop.hiera_structure('use_ssl/swift_internal_hostname')
    elsif swift['management_vip']
      internal_protocol = 'http'
      internal_address  = swift['management_vip']
    else
      internal_protocol = 'http'
      internal_address  = Noop.hiera('management_vip')
    end

    public_url          = "#{public_protocol}://#{public_address}:8080/v1/AUTH_%(tenant_id)s"
    admin_url           = "#{internal_protocol}://#{internal_address}:8080/v1/AUTH_%(tenant_id)s"

    public_url_s3       = "#{public_protocol}://#{public_address}:8080"
    admin_url_s3        = "#{internal_protocol}://#{internal_address}:8080"

    it 'class swift::keystone::auth should contain correct *_url' do
      should contain_class('swift::keystone::auth').with('public_url' => public_url)
      should contain_class('swift::keystone::auth').with('admin_url' => admin_url)
      should contain_class('swift::keystone::auth').with('internal_url' => admin_url)
    end

    it 'class swift::keystone::auth should contain correct S3 endpoints' do
      should contain_class('swift::keystone::auth').with('public_url_s3' => public_url_s3)
      should contain_class('swift::keystone::auth').with('admin_url_s3' => admin_url_s3)
      should contain_class('swift::keystone::auth').with('internal_url_s3' => admin_url_s3)
    end
  end

  test_ubuntu_and_centos manifest
end
