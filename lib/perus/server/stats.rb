require 'json'

module Perus::Server
    class Stats
        MAX_HISTORY = 10
        attr_reader :data

        # data format (json):
        # {
        #   "vacuums": [
        #     ["ISO time", duration (int) || 'failed'],
        #     ...
        #   ]
        # }

        def initialize
            if File.exists?(Server.options.stats_path)
                data = IO.read(Server.options.stats_path)
                unless data.empty?
                    @data = JSON.parse(data)
                    return
                end
            end

            @data = {
                'vacuums' => [],
                'alerts_caches' => [],
                'cleans' => []
            }
        end

        def save
            IO.write(Server.options.stats_path, JSON.dump(@data))
        end

        # vacuuming
        def last_vacuum
            entry = @data['vacuums'].last
            entry ? entry.first : nil
        end

        def vacuum_time
            entry = @data['vacuums'].last
            entry ? entry.last : nil
        end

        def average_vacuum_time
            entries = @data['vacuums']
            return nil if entries.empty?
            ints = entries.map(&:last).select {|time| time.is_a?(Numeric)}
            ints.reduce(:+).to_f / ints.length
        end

        def self.vacuumed!(time)
            stats = Stats.new
            list = stats.data['vacuums']
            list << [Time.now.to_s, time]
            
            if list.length > MAX_HISTORY
                list.drop(list.length - MAX_HISTORY)
            end

            stats.save
        end

        # alerts caching
        def last_alerts_cache
            entry = @data['alerts_caches'].last
            entry ? entry.first : nil
        end

        def alerts_cache_time
            entry = @data['alerts_caches'].last
            entry ? entry.last : nil
        end

        def average_alerts_cache_time
            entries = @data['alerts_caches']
            return nil if entries.empty?
            ints = entries.map(&:last).select {|time| time.is_a?(Numeric)}
            ints.reduce(:+).to_f / ints.length
        end

        def self.alerts_cached!(time)
            stats = Stats.new
            list = stats.data['alerts_caches']
            list << [Time.now.to_s, time]
            
            if list.length > MAX_HISTORY
                list.drop(list.length - MAX_HISTORY)
            end

            stats.save
        end

        # cleaning
        def last_clean
            entry = @data['cleans'].last
            entry ? entry.first : nil
        end

        def clean_time
            entry = @data['cleans'].last
            entry ? entry.last : nil
        end

        def average_clean_time
            entries = @data['cleans']
            return nil if entries.empty?
            ints = entries.map(&:last).select {|time| time.is_a?(Numeric)}
            ints.reduce(:+).to_f / ints.length
        end

        def self.cleaned!(time)
            stats = Stats.new
            list = stats.data['cleans']
            list << [Time.now.to_s, time]
            
            if list.length > MAX_HISTORY
                list.drop(list.length - MAX_HISTORY)
            end

            stats.save
        end
    end
end
