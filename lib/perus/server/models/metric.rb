require 'uri'

module Perus::Server
    class Metric < Sequel::Model
        plugin :serialization
        many_to_one :system
        serialize_attributes :json, :file

        def numeric?
            type == 'num'
        end

        def string?
            type == 'str'
        end

        def file?
            type == 'file'
        end

        def url
            prefix = URI(Server.options.uploads_url)
            path = File.join(system_id.to_s, file['filename'])
            (prefix + path).to_s
        end

        def self.add(name, system_id, type, file_data = nil)
            existing = Metric.where(system_id: system_id, name: name, type: type).first

            if existing
                return if type != 'file'
                record = existing
            else
                record = Metric.new(system_id: system_id, name: name, type: type)
            end

            record.file = file_data
            record.save
        end

        def self.add_numeric(name, system_id)
            self.add(name, system_id, 'num')
        end

        def self.add_string(name, system_id)
            self.add(name, system_id, 'str')
        end

        def self.add_file(name, system_id, file_data)
            self.add(name, system_id, 'file', file_data)
        end
    end
end
