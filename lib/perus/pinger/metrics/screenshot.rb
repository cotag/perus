module Perus::Pinger
    class Screenshot < Command
        description 'Takes a screenshot of the primary screen on the client and
                     uploads it. The screenshot is saved to "path" before being
                     uploaded. Valid values for "path" are contained in the
                     pinger config file.'
        option :path, default: '/tmp/screenshot.jpg', restricted: true
        option :resize, default: '20%'
        metric!

        def run
            if darwin?
                if options.resize[-1] != '%'
                    raise 'Non percent resize option unsupported by OS X currently'
                else
                    percent = options.resize.to_f / 100
                end

                shell('screencapture -m -t jpg -x #{options.path}')
                width  = shell('sips -g pixelWidth #{options.path}').match(/pixelWidth: (\d+)/)[1]
                height = shell('sips -g pixelHeight #{options.path}').match(/pixelHeight: (\d+)/)[1]
                shell('sips -z #{height.to_i * percent} #{width.to_i * percent} #{options.path}')
            else
                shell('export DISPLAY=:0; import -window root -resize #{options.resize} #{options.path}')
            end

            @screenshot_file = File.new(options.path)
            {screenshot: @screenshot_file}
        end

        def cleanup
            @screenshot_file.close unless @screenshot_file.closed?
            File.delete(options.path)
        end
    end
end
