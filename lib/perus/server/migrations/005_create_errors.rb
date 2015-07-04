Sequel.migration do
    up do
        create_table(:errors) do
            primary_key :id
            Integer :system_id, null: false
            Integer :timestamp, null: false
            String  :module, null: false
            String  :description, null: false
        end
    end

    down do
        drop_table(:errors)
    end
end
