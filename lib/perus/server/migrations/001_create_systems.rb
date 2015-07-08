Sequel.migration do
    up do
        create_table(:systems) do
            primary_key :id
            String  :name, null: false, unique: true
            String  :display_name
            String  :orientation
            Integer :group_id
            Integer :config_id
            String  :links, text: true
            String  :ip
            String  :metrics, text: true
            Integer :last_updated
        end
    end

    down do
        drop_table(:systems)
    end
end
