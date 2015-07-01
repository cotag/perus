require 'fileutils'
require 'json'
require 'uri'

class Server::System < Sequel::Model
    plugin :validation_helpers
    many_to_one :config
    many_to_one :group
    one_to_many :values

    def uploads_dir
        @uploads_dir ||= File.join(Server.options.uploads_dir, id.to_s)
    end

    def save_uploads(names, params)
        # ensure the uploads directory exists for this system
        FileUtils.mkdir_p(uploads_dir)

        # delete any previous files - no history is kept for uploads

        # upload filenames and mimetypes are stored on the system object so we
        # can serve files with the correct name and type
        new_uploads = {}

        names.each do |name|
            filename = params[name][:filename]
            mimetype = params[name][:type]
            file = params[name][:tempfile]

            # store the file
            File.open(File.join(uploads_dir, filename), 'wb') do |f|
                f.write file.read
            end

            # store upload details
            new_uploads[name] = {filename: filename, mimetype: mimetype}
        end

        self.uploads = new_uploads.to_json
        save
    end

    def upload_urls
        return {} unless uploads
        entries = JSON.parse(uploads)
        prefix  = URI(Server.options.uploads_url)

        # map each upload file to its public url
        pairs = entries.collect do |(name, upload)|
            path = File.join(id.to_s, upload['filename'])
            [name, (prefix + path).to_s]
        end

        # convert to name => url hash
        Hash[pairs]
    end

    def screenshot_url
        return '' unless uploads

        # some systems may not have a screenshot
        entries = JSON.parse(uploads)
        return '' unless entries['screenshot']

        # construct the public url for the upload
        prefix = URI(Server.options.uploads_url)
        path = File.join(id.to_s, entries['screenshot']['filename'])
        (prefix + path).to_s
    end

    def validate
        super
        validates_presence  :name
        validates_unique    :name
    end
end
