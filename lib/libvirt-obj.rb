
begin
  require 'libvirt'
  require 'xmlsimple'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  require 'libvirt'
  require 'xmlsimple'
end

module Libvirt
  dir = File.dirname(__FILE__)
  require File.join(dir,'hypervisor.rb')
  require File.join(dir,'domain.rb')
  require File.join(dir,'network.rb')
  require File.join(dir,'storage_pool.rb')
  require File.join(dir,'storage_vol.rb')
end
