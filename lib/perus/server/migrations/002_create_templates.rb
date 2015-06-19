Sequel.migration do
    up do
        create_table(:templates) do
            primary_key :id
            String :name, null: false, unique: true
            String :config, text: true
        end
    end

    down do
        drop_table(:templates)
    end
end
