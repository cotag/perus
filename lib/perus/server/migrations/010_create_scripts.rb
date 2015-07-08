Sequel.migration do
    up do
        create_table(:scripts) do
            primary_key :id
            String :name, null: false, unique: true
            String :description
        end
    end

    down do
        drop_table(:scripts)
    end
end
