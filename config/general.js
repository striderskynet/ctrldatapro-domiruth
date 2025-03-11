export const config = {
    port: 3000, // Local Listening port
    cron: 5, // Process time in Minutes
    endpoint: 'http://sidinterface.domiruth.com/api/Facturacion/ProcessTicket', // Remote client endpoint

    tourplan_db: { // Remote tourplan database configuration
        host: '177.93.11.107', // TODO: Define a hostname instead of IP Address, throw DeprecationWarning in Console.
        port: '17501',
        user: 'DOMIRU',
        pass: 'hcn4@=9F]"Qru;HG7SDe#W',
        db: 'LA-DOMIRU',
        dialect: "mssql",
        logging: false,
        dialectOptions: {
            requestTimeout: 180000,
            ssl: {
                require: true,
                rejectUnauthorized: false
            }
        },
        pool: {
            max: 5,
            min: 0,
            acquire: 6000,
            idle: 10000
        }
    },
    postgres_db: { // Local postgres database config
        host: "127.0.0.1",
        user: "postgres",
        pass: "kkfuak123",
        db: "domiruth",
        dialect: "postgres",
        logging: false,
        dialectOptions: {
        },
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000
        }
    }
}

export default config;