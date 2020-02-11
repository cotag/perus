Sequel.migration do
    up do
        execute("ALTER TABLE values ALTER COLUMN timestamp TYPE bigint")
        execute("ALTER TABLE errors ALTER COLUMN timestamp TYPE bigint")
        execute("ALTER TABLE actions ALTER COLUMN timestamp TYPE bigint")
        execute("ALTER TABLE active_alerts ALTER COLUMN timestamp TYPE bigint")

        execute("ALTER TABLE values ALTER COLUMN id TYPE bigint")
        execute("ALTER TABLE metrics ALTER COLUMN id TYPE bigint")
        execute("ALTER TABLE alerts ALTER COLUMN id TYPE bigint")
        execute("ALTER TABLE active_alerts ALTER COLUMN id TYPE bigint")
        execute("ALTER TABLE systems ALTER COLUMN id TYPE bigint")

        # If a reset needs to be made due to ID limit
        # "ALTER SEQUENCE values_id_seq RESTART WITH 1;"
    end
end
