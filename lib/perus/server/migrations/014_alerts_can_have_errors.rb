Sequel.migration do
    up do
        alter_table(:alerts) do
            add_column :errors, String
        end
    end

    down do
        alter_table(:alerts) do
            drop_column :errors
        end
    end
end
