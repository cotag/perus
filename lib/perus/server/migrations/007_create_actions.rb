Sequel.migration do
    up do
        create_table(:actions) do
            primary_key :id
            Integer :system_id, null: false
            Integer :command_config_id
            Integer :script_id
            Integer :timestamp
            Boolean :success
            String  :response
            String  :file, text: true
        end
    end

    down do
        drop_table(:actions)
    end
end
