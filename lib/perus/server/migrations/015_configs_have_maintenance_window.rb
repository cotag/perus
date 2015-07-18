Sequel.migration do
    up do
        alter_table(:configs) do
            add_column :maintenance, String
        end
    end

    down do
        alter_table(:configs) do
            drop_column :maintenance
        end
    end
end
