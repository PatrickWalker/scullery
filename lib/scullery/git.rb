require 'git'


module Scullery
    class Git
        attr_reader :repo_path


        def initialize(repo_path)
            @repo_path = repo_path
            @repo = ::Git.open(repo_path)
        end


        # Returns the highest sequence number currently stored in the git
        # history.
        def get_latest_sequence_number
            begin
                message = @repo.object('HEAD').message
            rescue
                # Most likely and initially empty repo.
                return nil
            end

            match = /^X-CouchDB-Sequence: (\d+)$/.match(message)

            return match ? match[1] : nil
        end


        # Save the content of the given document_id, and add to index.
        def add_document(document_type, document_id, content)
            path = get_couchdb_document_path(document_id)
            add_file(path, content)
        end



        # Delete the document and stage the deletion.
        def delete_document(document_type, document_id)
            path = get_couchdb_document_path(document_id)
            delete_file(path)
        end



        # Commits the currently staged changes, recording the sequence number
        # in the commit message.
        def commit(sequence_number)
            message = "X-CouchDB-Sequence: #{sequence_number}\n"

            Dir.chdir(@repo_path) do
                if !@repo.commit_all(message)
                    raise "commit failed!"
                end
            end
        end


        # Write to the content to the given path, and add to index.
        def add_file(path, content)
            Dir.chdir(@repo_path) do
                FileUtils.mkdir_p(File.dirname(path))

                File.open(path, 'wb') do |io|
                    io.write(content)
                end

                @repo.add(path)
            end
        end


        # Delete the file of the given path, and stage the deletion.
        def delete_file(path)
            Dir.chdir(@repo_path) do
                File.delete(path)
                @repo.remove(path)
            end
        end


        # Stages a file to the index.
        def stage(path)
            Dir.chdir(@repo_path) do
                @repo.add(path)
            end
        end


        # Returns the path within the repo where the CouchDB document is
        # stored.
        def get_couchdb_document_path( document_id)
            return File.join('couchdb_documents', document_id)
        end
    end
end
