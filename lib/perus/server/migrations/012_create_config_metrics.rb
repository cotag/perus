Sequel.migration do
    up do
        create_table(:config_metrics) do
            primary_key :id
            Integer :config_id, null: false
            Integer :command_config_id, null:false
            Integer :order, null: false
        end
    end

    down do
        drop_table(:config_metrics)
    end
end
