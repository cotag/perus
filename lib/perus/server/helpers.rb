module Perus::Server
    module Helpers
        def load_site_information
            @site_name = Server.options.site_name
            @groups = Group.all
        end

        def nav_item(path, name, li = true)
            if path.start_with?('/admin/')
                klass = request.path_info.start_with?(path) ? 'selected' : ''
            else
                klass = request.path_info == path ? 'selected' : ''
            end
            anchor = "<a class=\"#{klass}\" href=\"#{path}\">#{name}</a>"
            li ? "<li>#{anchor}</li>" : anchor
        end

        def command_actions
            commands = Perus::Pinger::Command.subclasses.reject(&:metric?)
            commands.reject(&:abstract?)
        end

        def command_metrics
            metrics = Perus::Pinger::Command.subclasses.select(&:metric?)
            metrics.reject(&:abstract?)
        end

        def clean_arrows(text)
            text.gsub('<', '&lt;').gsub('>', '&gt;')
        end

        def url_prefix
            Server.options.url_prefix
        end
    end
end
