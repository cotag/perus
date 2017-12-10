Sequel.migration do
    up do
        execute("ALTER TABLE values CHANGE timestamp timestamp BIGINT")
        execute("ALTER TABLE errors CHANGE timestamp timestamp BIGINT")
        execute("ALTER TABLE actions CHANGE timestamp timestamp BIGINT")
        execute("ALTER TABLE active_alerts CHANGE timestamp timestamp BIGINT")
    end
end
