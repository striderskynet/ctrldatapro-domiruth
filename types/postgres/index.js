import Sequelize from 'sequelize';
import config from '../../config/general.js';
import { documents, documents_details, documents_types } from './type_documents.js';
import { errors } from './type_errors.js';
import { interfaces } from './type_interfaces.js';
import { jobs } from './type_jobs.js';
import { querys } from './type_querys.js';
import { status } from './type_status.js';

const db = new Sequelize(config.postgres_db.db, config.postgres_db.user, config.postgres_db.pass, {
    host: config.postgres_db.host,
    dialect: config.postgres_db.dialect,
    dialectOptions: config.postgres_db.dialectOptions,
    logging: config.postgres_db.logging,
    pool: config.postgres_db.pool
})

// Types Declarations
db.documents = documents(db, Sequelize);
db.documents_types = documents_types(db, Sequelize);
db.documents_details = documents_details(db, Sequelize);
db.querys = querys(db, Sequelize);
db.interfaces = interfaces(db, Sequelize);
db.status = status(db, Sequelize);
db.errors = errors(db, Sequelize);
db.jobs = jobs(db, Sequelize);

// Associations
db.documents.hasMany(db.documents_details);

db.status.hasOne(db.querys);
db.status.hasOne(db.interfaces);
db.status.hasOne(db.errors);
db.status.hasOne(db.jobs);

db.documents_types.hasOne(db.querys);
db.documents_types.hasOne(db.interfaces);
db.documents_types.hasOne(db.jobs);

export default db;