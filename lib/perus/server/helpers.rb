module Perus::Server
    module Helpers
        def load_site_information
            @site_name = Server.options.site_name
            @groups = Group.all
        end

        def nav_item(path, name, li = true)
            klass = request.path_info == path ? 'selected' : ''
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
    end
end
