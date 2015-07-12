Sequel.migration do
    up do
        create_table(:active_alerts) do
            primary_key :id
            Integer :alert_id, null: false
            Integer :system_id, null: false
            Integer :timestamp, null:false
        end
    end

    down do
        drop_table(:active_alerts)
    end
end
