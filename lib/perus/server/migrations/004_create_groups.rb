Sequel.migration do
    up do
        create_table(:groups) do
            primary_key :id
            String :name, null: false
        end
    end

    down do
        drop_table(:groups)
    end
end
