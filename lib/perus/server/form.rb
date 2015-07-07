module Perus::Server
    class Form
        def initialize(record)
            @record = record
        end

        def field(field, type = nil, options = nil)
            field = field.to_s

            if type.nil?
                if @record.class.association_reflections.include?(field.to_sym)
                    type = 'association'
                else
                    type = @record.db_schema[field.to_sym][:db_type]
                end
            end

            html = "<p><label for=\"#{field}\">#{field.titlecase}:</label><span>"

            case type
            when 'varchar(255)'
                html << input(field, options)
            when 'text'
                html << textarea(field, options)
            when 'association'
                html << association(field, options)
            when 'select'
                html << select(field, options)
            end

            # return the field plus any errors
            html << "</span></p>" << errors_for(field)
        end

        def input(field, options)
            "<input type=\"text\" name=\"record[#{field}]\" value=\"#{@record.send(field)}\">"
        end

        def textarea(field, options)
            "<textarea name=\"record[#{field}]\">#{@record.send(field)}</textarea>"
        end

        def association(field, options)
            reflection  = @record.class.association_reflections[field.to_sym]
            other_model = reflection[:class_name].constantize
            id_field    = reflection[:key]

            values = other_model.all.collect do |record|
                [record.id, record.name]
            end

            select(id_field, values)
        end

        def select(field, options)
            existing = @record.send(field)
            option_rows = options.collect do |(value, name)|
                selected = existing == value ? 'selected' : ''
                "<option value=\"#{value}\" #{selected}>#{name || value}</option>"
            end

            "<select name=\"record[#{field}]\">#{option_rows.join("\n")}</select>"
        end

        def errors_for(field)
            errors = @record.errors.on(field.to_sym)
            return '' unless errors
            field_name = field.titlecase
            descriptions = errors.map {|error| "#{field_name} #{error}"}
            "<p class=\"errors\">#{descriptions.join(', ')}</p>"
        end
    end
end
