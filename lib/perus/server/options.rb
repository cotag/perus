require 'inifile'

module Server::Options
    Defaults = {
        'uploads_dir' => './uploads',
        'db_path' => './perus.db',
        'listen' => '0.0.0.0',
        'port' => 3000,
        'site_name' => 'Perus'
    }

    def self.load(path)
        user_options = IniFile.load(path)
        user_options ||= {}  # if no user options were provided
        @options = Defaults.merge(user_options)
    end

    def self.method_missing(name, *params, &block)
        @options[name.to_s]
    end
end
