Sequel.migration do
    up do
        execute("ALTER TABLE values ALTER COLUMN timestamp TYPE bigint")
        execute("ALTER TABLE errors ALTER COLUMN timestamp TYPE bigint")
        execute("ALTER TABLE actions ALTER COLUMN timestamp TYPE bigint")
        execute("ALTER TABLE active_alerts ALTER COLUMN timestamp TYPE bigint")
    end
end
