require_relative './CouchDBListener'
require_relative './CouchDBServer'
require_relative '../scullery_fileutils.rb'
require_relative '../scullery_git.rb'
require_relative '../parseconfig.rb'

class CouchDBMonitor

  
  def initialize()
    c = ParseConfig.new('conf/scullery.conf')  #Read conf File
	##read
	notification_type=(c.params['notification_type'])    
    @@db_server = CouchDBServer.new( c.params['couchDBHost'], c.params['couchDBPort'])
    @@database_uri = c.params['database_uri']
    @@file_fetcher = Scullery::FileFetcher.new( c.params['checkSumHost'], c.params['user'], c.params['password'])
    @@git_client = Scullery::Git.new( c.params['gitRepo'])
    seq_id = @@git_client.get_latest_sequence_number()
    @@listener = CouchDBListener.new( @@db_server, @@database_uri, notification_type, seq_id, self )
		    
  end
  
  
  def notify(change_event)
   retrieve_document(change_event)
  end
  
  
  def retrieve_document(change_event)
    result = @@db_server.get("#{@@database_uri}#{change_event.id()}?rev=#{change_event.rev()}")
    json_document = result.body
    process_document(json_document, change_event)
    return json_document
  end
  
  def process_document(document, change_event)
  	 JSON.create_id = nil
  	 seq_id = change_event.seq
  	 document = JSON.parse(document)
  	 doc_type= document["chef_type"]
  	 json_class = document["json_class"]
  	  
  	   if !doc_type.nil?
   	 	 case doc_type.downcase
		 when "checksum"
			checksum_value = document["checksum"]
			@@file_fetcher.fetch_checksum_file(checksum_value, seq_id)
		 end
	   else
	   	doc_type = "design"
	   	
	   end
	   if ( (change_event.delete_operation?.nil?) && (!change_event.delete_operation?.eql?("true")))
	   	@@git_client.add_document(doc_type, change_event.id, document)
	   	@@git_client.commit(seq_id)
	   else
	   	#Only Delete Document if it exists in file system
	   	puts "Checking if File Exists #{File.join(@@git_client.repo_path,@@git_client.get_couchdb_document_path(change_event.id))}"
	   	if ::File.exists?(File.join(@@git_client.repo_path,@@git_client.get_couchdb_document_path(change_event.id)))	   		
	   		@@git_client.delete_document(doc_type, change_event.id)
	   	end
	   end
  end
  
end
