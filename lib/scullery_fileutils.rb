require 'net/ssh'
require 'net/scp'
require_relative './scullery_git.rb'
require_relative 'parseconfig.rb'



module Scullery
    class FileFetcher
        attr_reader :host
        attr_reader :user
        attr_reader :pass

        def initialize(host, username, password)
		   c = ParseConfig.new('conf/scullery.conf')
       	   @host = host
           @user = username
           @password = password    
		   @git_client = Scullery::Git.new( c.params['gitRepo'])
           @target_dir = @git_client.repo_path
        end
	

	def fetch_checksum_file(checksum,seq_id)
		
		source_path = build_checksum_path(checksum)
        checksum_dir = File.join('checksum_files', checksum[0..1])
        checksum_path = File.join(checksum_dir, checksum)
        if ! File.exists?(File.join(@target_dir, checksum_dir))
            FileUtils.mkdir_p File.join(@target_dir, checksum_dir)
		end
        target_path = File.join(@target_dir, checksum_path)
		#Net::SSH.start("10.50.60.170", "root",:password => "welcome") do |session|
		Net::SSH.start(@host, @user,:password => @password) do |session|
		 	session.scp.download! source_path, target_path
		 	#Check for existence of target_file
		 	if !File.exists?(target_path)
		 		#Throw exception
		 	else
		 		
		 		@git_client.stage(checksum_path)
		 		
		 		@git_client.commit(seq_id)
		 	end
		 	
		end
	end
	
	
	def build_checksum_path(checksum)
		
		#Should always be /var/chef/checksums
		path = "/var/chef/checksums/" 
		#Next folder is the first two digits of the checksum
		path = "#{path}#{checksum[0..1]}/#{checksum}"
		#Filename is checksum#	
		return path
	end
    end
end    
