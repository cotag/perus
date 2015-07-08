Sequel.migration do
    up do
        create_table(:metrics) do
            primary_key :id
            String  :name, null: false
            String  :system_id, null: false
            String  :type, null: false
            String  :file, text: true
            index [:system_id, :name]
        end
    end

    down do
        drop_table(:metrics)
    end
end
