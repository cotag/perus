Sequel.migration do
    change do
        change_column :values, :timestamp, :bigint
        change_column :errors, :timestamp, :bigint
        change_column :actions, :timestamp, :bigint
        change_column :active_alerts, :timestamp, :bigint
    end
end
