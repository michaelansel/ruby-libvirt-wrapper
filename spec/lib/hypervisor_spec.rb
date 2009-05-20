require File.join(File.dirname(__FILE__),"..","..","lib","libvirt-obj.rb")

def not_read_only
  pending("Unable to test this with a read-only hypervisor") if @hypervisor.read_only?
end

def get_hypervisor(&block)
  @hypervisor = nil
  begin
    @hypervisor = yield
    @hypervisor.connected? || pending("Unable to test without a valid hypervisor connection")
  rescue ArgumentError
    pending("Unable to obtain a valid hypervisor connection")
  end
end

shared_examples_for "all hypervisors" do

  it "should have a valid connection" do
    @hypervisor.should be_connected
  end

  it "should have a valid architecture" do
    @hypervisor.arch.should =~ /(i[356]86)|(x86_64)/ # This should probably allow for more architectures
  end

  it "should have hvm guests" do
    @hypervisor.guests.should_not be_nil
  end

  after :each do
    @hypervisor.disconnect
  end
end

describe "The default hypervisor" do
  it_should_behave_like "all hypervisors"

  before :each do
    get_hypervisor { Libvirt::Hypervisor.new }
  end

  it "should be connected" do
    @hypervisor.should be_connected
  end

end

describe "The QEMU system hypervisor" do
  it_should_behave_like "all hypervisors"

  before :each do
    get_hypervisor { Libvirt::Hypervisor.new(:uri => "qemu:///system") }
  end
end
