import Sequelize from 'sequelize';
import config from '../../config/general.js';

const db = new Sequelize(config.tourplan_db.db, config.tourplan_db.user, config.tourplan_db.pass, {
    host: config.tourplan_db.host,
    port: config.tourplan_db.port,
    dialect: config.tourplan_db.dialect,
    dialectOptions: config.tourplan_db.dialectOptions,
    logging: config.tourplan_db.logging,
    pool: config.tourplan_db.pool
})

export default db;