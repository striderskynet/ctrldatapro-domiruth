import fs from 'fs';
import { QueryTypes } from 'sequelize';
import config from '../config/general.js';
import tourplan_db from '../types/tourplan/index.js';

const get_documents = async () => {
    console.log("Retrieving query from:", '\"controllers/query.sql\"');
    let query = fs.readFileSync('controllers/query.sql', 'utf8');
    console.log("Accessing remote server:", config.tourplan_db.dialect + '://' + config.tourplan_db.host + ':' + config.tourplan_db.port)
    const docs = await tourplan_db.query(query, { type: QueryTypes.SELECT });

    return docs;
}
const postgres = {
    get_documents: get_documents
}
export default postgres;