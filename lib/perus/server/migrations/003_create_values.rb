Sequel.migration do
    up do
        create_table(:values) do
            primary_key :id
            Integer :system_id, null: false
            Integer :timestamp, null: false
            String  :metric, null: false
            Float   :num_value
            String  :str_value

            # a covering index is used so no secondary lookups are required
            # when querying for all metric values for a system. queries are
            # constrained on system_id only. using timestamp as the second
            # component of the index implicitly sorts the rows by timestamp
            # satisfying `order by timestamp'.
            index [:system_id, :timestamp, :metric, :num_value, :str_value]
        end
    end

    down do
        drop_table(:values)
    end
end
