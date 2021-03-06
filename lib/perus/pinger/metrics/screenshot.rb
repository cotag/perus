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

                shell("screencapture -m -t jpg -x #{options.path}")
                width  = shell("sips -g pixelWidth #{options.path}").match(/pixelWidth: (\d+)/)[1]
                height = shell("sips -g pixelHeight #{options.path}").match(/pixelHeight: (\d+)/)[1]

                # sips helpfully prints data to stderr, so it's run with
                # backticks to avoid thowing an exception on success
                `sips -z #{height.to_i * percent} #{width.to_i * percent} #{options.path}`
            else
                shell("export DISPLAY=:0; scrot --silent --thumb #{options.resize.to_i} #{options.path}")
            end

            # scrot produced two files: path.ext and path-thumb.ext
            @original_path = options.path
            name_parts = File.basename(options.path).split('.')
            name_parts[-2] += '-thumb'
            @thumbnail_path = File.join(
                File.dirname(options.path),
                name_parts.join('.')
            )

            @screenshot_file = File.new(@thumbnail_path)
            {screenshot: @screenshot_file}
        end

        def cleanup
            unless @screenshot_file.nil? || @screenshot_file.closed?
                @screenshot_file.close
            end

            File.delete(@original_path)
            File.delete(@thumbnail_path)
        end
    end
end
