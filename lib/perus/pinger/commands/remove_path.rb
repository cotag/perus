require'fileutils'

module Perus::Pinger
    class RemovePath < Command
        description 'Deletes a file or folder. If "path" is a folder, all files
                     and folders within the folder are deleted as well. Valid
                     values for "path" are contained in the pinger config file.'
        option :path, restricted: false

        def run
            FileUtils.rm_rf([File.expand_path(options.path)], secure: true)
            true # with no exceptions, the removal was successful
        end
    end
end
