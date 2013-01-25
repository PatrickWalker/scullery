require 'net/http'
require 'uri'
require 'cgi'
require 'json'
require 'rubygems'

module Scullery
    module CouchDB
        class Listener
	   
	        # Creates the CouchDBListener.
	        # == Parameters:
	        # couch_db_server::    	
	        #	couch db server
	        # database_uri::
	        #	SSH Username to retrieve the checksum files
	        # notification_type::
	        #	CouchDB notification_type
	        # seq_id::
	        #	Will be used as the since parameter to make sure we don't process events twice
	        # event_handler::
     		#	Handles change events
            def initialize(couch_db_server, database_uri, notification_type, seq_id=nil, event_handler)
              @couch_db_server = couch_db_server
              puts "couch_db_server[#{couch_db_server.inspect()}]"
              @database_uri = database_uri
              @notification_type = notification_type
              @event_hander = event_handler

              if seq_id.nil?
                seq_id =  0
              end
              @since = seq_id
              puts "since #{@since}"

              @completeResponse = ""

              listen()
            end
	    
	    
    	    # Long life listener
            def listen()
              params = {:feed => @notification_type, :heartbeat => 30000}
              http_get(@couch_db_server.host, @couch_db_server.port, "#{@database_uri}_changes?feed=#{@notification_type}&heartbeat=5000&since=#{@since}")
            end

          #Makes http request 
          def http_get(baseurl, port, artifacturl)
            Net::HTTP.start(baseurl, port)  do |http|
              http.get(artifacturl) do | resp |
                puts "resp[#{resp}]"
                if resp != nil and resp.to_s.strip.length != 0
                        handleResponse( resp )
                else
                  puts "empty response"
                end
              end
            end
          end

	   # Handles the changes objects
          def handleResponse( resp )

            @completeResponse += resp
            validJson = validJson?( @completeResponse )
            if validJson
              change_event = ChangeEventInfo.new( @completeResponse )
              @completeResponse = ""
              @event_hander.notify( change_event )
            end
          end


          def validJson? (data)
            begin
              JSON.parse(data)
              return true
            rescue Exception => e
              return false
            end
          end

        end

    end
end
