module Server::Helpers
    def load_site_information
        @site_name = Server.options.site_name
        @groups = Server::Group.all
    end

    def nav_item(path, name, li = true)
        klass = request.path_info == path ? 'selected' : ''
        anchor = "<a class=\"#{klass}\" href=\"#{path}\">#{name}</a>"
        li ? "<li>#{anchor}</li>" : anchor
    end
end
