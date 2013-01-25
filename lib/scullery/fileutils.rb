require 'net/ssh'
require 'net/scp'


module Scullery
    class FileFetcher
      attr_reader :host
      attr_reader :user
      attr_reader :pass

    # Creates the FileFetcher object which is responsible for retrieving checksum files from the Chef Server.
    # These files represent the physical cookbook files so without them any restore wouldn't be feasible
    # == Parameters:
    # host::
    #	A string refering to the chef host server
    # username::
    #	SSH Username to retrieve the checksum files
    # password::
    #	SSH Password to retrieve the checksum files
      def initialize(host, username, password)
         c = ParseConfig.new('conf/scullery.conf')
         @chef_host = host
         @chef_user = username
         @chef_password = password

         @chef_dir = "/var/chef"
         @chef_checksum_dir = "/var/chef/checksums"

         @git_repos_path =  c.params['gitRepo']
         @git_client = Scullery::Git.new(@git_repos_path)
      end

	 # Retrieves the file using the net-scp and net-ssh gems
   	 # We save the files in a checksum_files folder under the main data store repo defined in the config file
   	 # == Parameters:
   	 # checksum::
   	 #	The name of the checksum file to fetch. This is obtained from the couchdb checksum document
   	 # seq_id::
   	 #	We use this to create the git commit message. Correlates with the CouchDB changes sequence ID
      def fetch_checksum_file(checksum,seq_id)

        source_path = build_checksum_path(checksum)
        checksum_dir = File.join('checksums', checksum[0..1])
        checksum_path = File.join(checksum_dir, checksum)
        if ! File.exists?(File.join(@git_repos_path, checksum_dir))
            FileUtils.mkdir_p File.join(@git_repos_path, checksum_dir)
        end
        target_path = File.join(@git_repos_path, checksum_path)
        puts "Net::SSH.start(#{@chef_host}, #{@root}"
        Net::SSH.start(@chef_host, @chef_user,:password => @chef_password) do |session|
          session.scp.download! source_path, target_path
          #Check for existence of target_file
          if !File.exists?(target_path)
            #Throw exception
          else

            @git_client.stage(checksum_path)

            #Check for existence of target_file
            if !File.exists?(target_path)
              #Throw exception
            else

              @git_client.stage(checksum_path)

              @git_client.commit(seq_id)
            end
          end
        end
      end

      # Used during the restore. Copies the files from Source to the Chef Server
      def restore_checksum_files()
        git_checksum_dir = File.join(@git_repos_path, 'checksums')
        Net::SSH.start(@chef_host, @chef_user,:password => @chef_password) do |session|
          channel = session.scp.upload("#{git_checksum_dir}", @chef_dir ,:recursive => true)
          channel.wait
        end
      end


       # Calculates the path on the remote server that the Checksum file will be stored under
       # == Parameters:
       # checksum::
       #	The name of the checksum file to fetch. This is obtained from the couchdb checksum document
      def build_checksum_path(checksum)

        #Should always be /var/chef/checksums
        #Next folder is the first two digits of the checksum
        path = "#{@chef_checksum_dir}/#{checksum[0..1]}/#{checksum}"
        #Filename is checksum#
        return path
      end

    end
end
