require 'inifile'

module Server::Config
    Defaults = {
        'uploads_dir' => './uploads',
        'db_path' => './perus.db',
        'listen' => '0.0.0.0',
        'port' => 3000,
        'site_name' => 'Perus'
    }

    def self.load(path)
        user_config = IniFile.load(path)
        user_config ||= {}  # if no user config was provided
        @config = Defaults.merge(user_config)
    end

    def self.method_missing(name, *params, &block)
        @config[name.to_s]
    end
end
