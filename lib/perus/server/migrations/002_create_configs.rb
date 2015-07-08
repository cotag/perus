Sequel.migration do
    up do
        create_table(:configs) do
            primary_key :id
            String :name, null: false, unique: true
        end
    end

    down do
        drop_table(:configs)
    end
end
