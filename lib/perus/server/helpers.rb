module Perus::Server
    module Helpers
        def load_site_information
            @site_name = Server.options.site_name
            @groups = Group.all
        end

        def nav_item(path, name, li = true)
            # when hosted behind a fronting server such as nginx, path_info
            # will start with '/' not url_prefix
            adjusted_path = path
            if path.index(url_prefix) == 0
                adjusted_path = path.sub(url_prefix, '/')
            end

            # admin links are highlighted for sub pages as well as their own
            # top level page. e.g 'groups' matches '/groups/1'
            if adjusted_path.start_with?('/admin/')
                klass = request.path_info.start_with?(adjusted_path) ? 'selected' : ''
            else
                klass = request.path_info == adjusted_path ? 'selected' : ''
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

        def escape_quotes(text)
            text.to_s.gsub('"', '&quot;')
        end

        def url_prefix
            Server.options.url_prefix
        end
    end
end
