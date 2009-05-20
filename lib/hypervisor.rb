module Libvirt
  class Hypervisor
    HYPERVISOR_CACHE_TIMEOUT = 5 #seconds

    def initialize(opts={})
      @uri = opts[:uri] || ""
      @read_only = opts[:read_only] || false
      @connection = nil

      # Open a connection
      begin
        if @read_only
          # Open a read-only connection
          @connection = Libvirt::open_read_only(@uri)

        else
          # Open a normal (read/write) connection
          @connection = Libvirt::open(@uri)
        end

      # Failed to connect
      rescue Libvirt::ConnectionError
        @connection.close if not @connection.nil?

        if @read_only
          # Nothing else we can try

          #e = $!
          #STDERR.puts "CONNECTION ERROR! :: #{e.inspect}"
          #STDERR.puts "Libvirt function name: #{e.libvirt_function_name}" unless e.libvirt_function_name.nil?
          #STDERR.puts "Libvirt message: #{e.libvirt_message}" unless e.libvirt_message.nil?

          @connection = nil
          raise ArgumentError, "Unable to connect to hypervisor"

        else
          # Try to open a read-only connection instead
          STDERR.puts "Falling back to read-only connection"
          opts[:read_only] = true
          initialize(opts)
        end
      end

      ObjectSpace.define_finalizer(self, lambda{puts "Connection closed #{@connection.close ? "successfully" : "unsuccessfully"}"})

      # Capabilities
      @arch = ""
      @features = []
      @guests = []

      @last_updated = 0

      update
    end

    def arch ; @arch ; end
    def features ; @features ; end
    def guests ; @guests ; end

    def connected? ; @connection and @connection.uri != nil ; end
    def read_only? ; @read_only ; end
    def disconnect ; @connection.close if connected? ; end


    def update(opts={ :force => false })
      return unless stale or opts[:force]

      load_capabilities

      @last_updated = Time.now
    end

    def stale
      (Time.now - @last_updated).to_i > HYPERVISOR_CACHE_TIMEOUT
    end

    def load_capabilities
      capabilities_xml = @connection.capabilities
      capabilities = XmlSimple.xml_in(capabilities_xml)

      @arch = capabilities['host'][0]['cpu'][0]['arch'][0]
      @features = capabilities['host'][0]['cpu'][0]['features']
      @guests = capabilities['guest']

      @arch and @features and @guests
    end

  end
end
