module Metrics
    class Screenshot < UploadMetric
        option :path, '/tmp/screenshot.jpg'
        option :resize, '20%'

        def attach(uploads)
            `export DISPLAY=:0; import -window root -resize #{options.resize} #{options.path}`
            @screenshot_file = File.new(options.path)
            uploads[:screenshot] = @screenshot_file
        end

        def cleanup
            @screenshot_file.close
            File.delete(options.path)
        end
    end
end
