require 'fileutils'
require 'json'
require 'uri'

module Perus::Server
    class System < Sequel::Model
        plugin :validation_helpers
        plugin :serialization

        many_to_one :config
        many_to_one :group
        one_to_many :values
        one_to_many :collection_errors, class_name: 'Perus::Server::Error'

        serialize_attributes :json, :metrics
        serialize_attributes :json, :uploads

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end


        # ---------------------------------------
        # metrics
        # ---------------------------------------
        def save_values(values, timestamp)
            # store the set of known metrics for this system. metrics have either
            # str or num values.
            self.metrics ||= {'str' => [], 'num' => []}

            values.each do |(metric_name, value)|
                attrs = {
                    system_id: id,
                    timestamp: timestamp,
                    metric: metric_name
                }

                if value.kind_of?(Numeric)
                    attrs[:num_value] = value
                    metrics['num'] << metric_name
                else
                    attrs[:str_value] = value
                    metrics['str'] << metric_name
                end

                Server::Value.create(attrs)
            end

            # on existing systems, adding values above will duplicate metric names
            metrics['num'].uniq!
            metrics['str'].uniq!
        end

        def latest(name)
            values_dataset.where(metric: name).order_by('timestamp desc').first
        end


        # ---------------------------------------
        # uploads
        # ---------------------------------------
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

            self.uploads = new_uploads
            save
        end

        def upload_urls
            return {} unless uploads
            prefix  = URI(Server.options.uploads_url)

            # map each upload file to its public url
            pairs = uploads.collect do |(name, upload)|
                path = File.join(id.to_s, upload['filename'])
                [name, (prefix + path).to_s]
            end

            # convert to name => url hash
            Hash[pairs]
        end

        def screenshot_url
            return '' unless uploads

            # some systems may not have a screenshot
            return '' unless uploads['screenshot']

            # construct the public url for the upload
            prefix = URI(Server.options.uploads_url)
            path = File.join(id.to_s, uploads['screenshot']['filename'])
            (prefix + path).to_s
        end
    end
end
