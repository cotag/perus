Sequel.migration do
    up do
        create_table(:command_configs) do
            primary_key :id
            String  :command, null: false
            String  :options, text: true
        end
    end

    down do
        drop_table(:command_configs)
    end
end
