Sequel.migration do
    up do
        create_table(:actions) do
            primary_key :id
            Integer :system_id, null: false
            String  :command, null: false
            String  :options, text: true
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
