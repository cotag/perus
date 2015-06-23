class Server::Form
    def initialize(record)
        @record = record
    end

    def field(field)
        field = field.to_s
        type = @record.db_schema[field.to_sym][:db_type]
        html = "<p><label for=\"#{field}\">#{field.titlecase}:</label><span>"

        case type
        when 'varchar(255)'
            html << input(field)
        when 'text'
            html << textarea(field)
        end

        # return the field plus any errors
        html << "</span></p>" << errors_for(field)
    end

    def input(field)
        "<input type=\"text\" name=\"record[#{field}]\" value=\"#{@record.send(field)}\">"
    end

    def textarea(field)
        "<textarea name=\"record[#{field}]\">#{@record.send(field)}</textarea>"
    end

    def association(field, other_type)
    end

    def errors_for(field)
        errors = @record.errors.on(field.to_sym)
        return '' unless errors
        field_name = field.titlecase
        descriptions = errors.map {|error| "#{field_name} #{error}"}
        "<p class=\"errors\">#{descriptions.join(', ')}</p>"
    end
end
