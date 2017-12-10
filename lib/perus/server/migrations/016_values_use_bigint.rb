Sequel.migration do
    change do
        change_column :values, :timestamp, :bigint
    end
end
