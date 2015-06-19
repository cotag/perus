Sequel.migration do
    up do
        create_table(:values) do
            primary_key :id
            Integer :system_id, null: false
            String  :metric, null: false
            Integer :timestamp, null: false
            Float   :value

            index [:system_id, :metric]
        end
    end

    down do
        drop_table(:values)
    end
end
