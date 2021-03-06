require 'fileutils'
require 'json'

module Perus::Server
    class System < Sequel::Model
        plugin :validation_helpers

        many_to_one :config
        many_to_one :group
        one_to_many :metrics
        one_to_many :values
        one_to_many :actions
        one_to_many :active_alerts
        one_to_many :collection_errors, class_name: 'Perus::Server::Error'

        def validate
            super
            validates_presence  :name
            validates_unique    :name
        end

        def after_destroy
            super

            # remove dependent records
            metrics.each(&:destroy)
            values.each(&:destroy)
            actions.each(&:destroy)
            collection_errors.each(&:destroy)
            active_alerts.each(&:destroy)

            # remove any uploaded files
            FileUtils.rm_rf([uploads_dir], secure: true)
        end

        def alert_class
            return '' if active_alerts.empty?
            severities = active_alerts.map(&:severity).uniq
            return 'error' if severities.include?('error')
            return 'warning' if severities.include?('warning')
            return 'notice' if severities.include?('notice')
        end

        def pending_actions
            actions_dataset.where(timestamp: nil).all
        end

        def action_hashes
            # actions referring to a command_config return a hash when calling
            # config_hashes, actions referring to scripts return an array.
            # flatten is needed to merge the two response types together.
            pending_actions.collect(&:config_hashes).flatten
        end

        def config_hash
            {
                id: id,
                metrics: config.metric_hashes,
                actions: pending_actions.map(&:config_hash).flatten
            }
        end


        # ---------------------------------------
        # metrics
        # ---------------------------------------
        def save_metric_errors(params, timestamp)
            # ignore errors during maintenance window
            return if config.in_maintenance?
            errors = JSON.parse(params['metric_errors'])

            errors.each do |module_name, module_errors|
                module_errors.each do |error|
                    Error.create(
                        system_id: id,
                        timestamp: timestamp,
                        module: module_name,
                        description: error
                    )
                end
            end
        end

        def save_values(params, timestamp)
            # store the set of known metrics for this system. metrics have either
            # str or num values.
            values = JSON.parse(params['metrics'])

            values.each do |(metric_name, value)|
                # file uploads are treated specially and don't need a value
                # record created for them
                if value.kind_of?(Hash)
                    file_data = save_file(params, value, metric_name)
                    Metric.add_file(metric_name, id, file_data)
                    next
                end

                attrs = {
                    system_id: id,
                    timestamp: timestamp,
                    metric: metric_name
                }

                if value.kind_of?(Numeric)
                    attrs[:num_value] = value
                    Metric.add_numeric(metric_name, id)
                else
                    attrs[:str_value] = value
                    Metric.add_string(metric_name, id)
                end

                Value.create(attrs)
            end
        end

        def latest(name)
            values_dataset.where(metric: name.to_s).order_by(:timestamp).last
        end

        def metric(name)
            metrics_dataset.where(name: name.to_s).first
        end


        # ---------------------------------------
        # actions
        # ---------------------------------------
        def save_actions(params, timestamp)
            actions = JSON.parse(params['actions'])

            actions.each do |id, result|
                # JSON.dump turns integer keys into strings
                action = Action.with_pk!(id.to_i)
                action.timestamp = timestamp

                if result == true
                    action.success = true
                elsif result.is_a?(Hash)
                    action.success = true
                    action.file = save_file(params, result, action.id)
                else
                    action.success = false
                    action.response = result.to_s
                end

                action.save
            end
        end


        # ---------------------------------------
        # files
        # ---------------------------------------
        def uploads_dir
            @uploads_dir ||= File.join(Server.options.uploads_dir, id.to_s)
        end

        def save_file(params, entry, name)
            # entry should be a hash with a single key 'file', which is the
            # key name used to find the file in params
            raise 'Invalid file upload' unless entry.is_a?(Hash) && entry.include?('file')

            # ensure the uploads directory exists for this system
            FileUtils.mkdir_p(uploads_dir)

            # files are sent as top level parameters. metrics rename files
            # with their own name (i.e 'screenshot' saves a file called
            # 'screenshot'), while actions rename files to the action id
            upload = params[entry['file']]

            # store the file
            name = name.to_s + File.extname(upload[:filename])
            File.open(File.join(uploads_dir, name.to_s), 'wb') do |f|
                f.write(upload[:tempfile].read)
            end

            # return details of the file so it can be served with the correct
            # original filename and mimetype
            {filename: name, original_name: upload[:filename], mimetype: upload[:type]}
        end

        def upload_urls
            file_metrics = metrics_dataset.where(type: 'file').all
            pairs = file_metrics.collect do |metric|
                [metric.name, metric.url]
            end

            # convert to name => url hash
            Hash[pairs]
        end

        def screenshot_url
            screenshot = metrics_dataset.where(name: 'screenshot').first
            screenshot ? screenshot.url : ''
        end
    end
end
