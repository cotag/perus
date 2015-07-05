Sequel.migration do
    up do
        create_table(:alerts) do
            primary_key :id
            String  :name, null: false, unique: true
            String  :code, text: true, null: false
            String  :severity, null: false
        end
    end

    down do
        drop_table(:alerts)
    end
end
