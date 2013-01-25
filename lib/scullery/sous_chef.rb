require 'find'
require 'json'

module Scullery
class SousChef
  
# Creates the SousChef which is responsible for the restore process.
  def initialize()
    @sourcepath = "/var/chef/checksums/"
    @file_fetcher = Scullery::FileFetcher.new( "10.50.60.170", "root", "welcome")
    @@db_server = CouchDBServer.new( "10.50.60.170", 5984)
    #@@db_server = CouchDBServer.new( "127.0.0.1", 5984)
    @@database_uri = "/chef/"
    puts "SousChef initialised"
  end

# Main restore process.
  def build_chef_server()    
    build_filesystem()
    build_couchDB()
  end

# Build physical checksum file system
  def build_filesystem()
    @file_fetcher.restore_checksum_files()
  end

# Creates a new couchdb database using the stored files
  def build_couchDB()
    couch_db_path = "C:\\Navinet\\FeatureTeam7\\OTG\\2013\\Repos\\ChefDataStore\\couchdb_documents"
    dirs          = ["_design", ""]

    for dir in dirs
      puts ""
      parent_dir_path = File.join(couch_db_path, dir)
      puts "dir [#{dir}] parent_dir_path [#{parent_dir_path}]"

      #RECURSIVE = Find.find( parent_dir_path ) do |item|
      Dir.foreach( parent_dir_path ) do |item|
        next if item == '.' or item == '..'

        # do work on real items
        filepath = File.join(parent_dir_path, item)
        is_file = File.file?(filepath)
        puts "item #{item} filepath #{filepath} is_file #{is_file}"

        if is_file
          populate_couchDB( filepath, item )
        else
          puts "item #{item} skipped"
        end
      end
    end
  end

# Sends the stored CouchDB documents to the new database
  def populate_couchDB( filepath, filename )
    JSON.create_id = nil
    puts "filepath #{filepath} - filename #{filename}"

    json_doc = JSON.parse(IO.read(filepath))
    real_json_doc = json_doc.to_json()
    puts "real_json_doc#{real_json_doc}"

    response = @@db_server.put("#{@@database_uri}#{filename}", real_json_doc)
  end

end

end
