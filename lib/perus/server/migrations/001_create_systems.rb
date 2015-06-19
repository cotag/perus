Sequel.migration do
    up do
        create_table(:systems) do
            primary_key :id
            String  :name, null: false
            String  :display_name
            String  :ip
            String  :orientation
            Integer :group_id
            String  :config, text: true
        end
    end

    down do
        drop_table(:systems)
    end
end
