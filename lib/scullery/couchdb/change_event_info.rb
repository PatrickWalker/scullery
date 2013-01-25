module Scullery
    module CouchDB
        class ChangeEventInfo

          @seq = 0
          @id = 0
          @rev = ""
	    	# Creates the Change Event Info object.
	    	# == Parameters:
	    	# json_string::    	
		#	A string representing the change event.
            def initialize(json_string)
              parsed = JSON.parse( json_string )
              @seq = parsed [ "seq" ]
              @id = parsed [ "id" ]
              @rev = parsed [ "changes" ].first[ "rev"]
              @delete_op = parsed["deleted"]
            end
	    
	    # == Returns
	    # seq::
	    #	Sequence Number of the change
            def seq()
              @seq
            end
	
	    # == Returns
	    # id::
	    #	Document ID
            def id()
              @id
            end

	    # == Returns
	    # rev::
	    #	Revision ID of the document
            def rev()
              @rev
            end
	   
	    # == Returns
	    # delete_op::
	    #	Indicates if the operation for couchdb was a delete
            def delete_operation?()
                @delete_op
            end
        end


    end
end
