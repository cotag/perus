Sequel.migration do
    up do
        create_table(:script_commands) do
            primary_key :id
            Integer :script_id, null: false
            Integer :command_config_id, null:false
            Integer :order, null: false
        end
    end

    down do
        drop_table(:script_commands)
    end
end
