import axios from 'axios';
import postgres_db from '../types/postgres/index.js';
import tourplan from './tourplan.js';

/** Send the documents to insert into the endpoint */
export const send_documents = async () => {
    const documents_result = await create_documents();

    if (!documents_result.values.length) console.log("No new documents detected.")

    for (const doc of documents_result.values) {
        const createInterface = await Interfaces.create({
            request: JSON.stringify(doc),
            response: '',
            processRounds: 1,
            httpStatus: 200,
            reference: `${doc.nroCotizacion}-${doc.idTipoDoc}`,
        });

        try {
            const endpoint = await sendPostRequest(doc);
            createInterface.response = JSON.stringify(endpoint);
            createInterface.save();
        } catch (error) {
            console.log("[ERROR] Failed to access API endpoint: ", error);
        }
    }
    return { success: true }
}

export const create_documents = async () => {
    let _result = [];
    try {
        const _documents = await tourplan.get_documents();
        if (!_documents) {
            return { success: true, message: "No documents to process." }
        }
        console.log("Retrieving %d documents.", _documents.length);

        for (const doc of _documents) {
            const val = await validate_document(`${doc.nroCotizacion}-${doc.idTipoDoc}`);

            if (val) {
                console.log(`[Add] ${doc.booking}, adding...`);
                _result.push(format_document(doc)); // Adding document to return list
            }
            else console.log(`[Exists] ${doc.booking}, skipping...`)
        }
    } catch (error) {
        console.log(error)
    }

    return { success: true, values: _result }
}

/** Validate if the documents exists locally
 * @constructor
 * @param {string} reference - Format of "{nroCotizacion}-{idTipoDoc}"
 */
const validate_document = async (reference) => {
    const val = await postgres_db.interfaces.findOne({ where: { reference: reference } });
    if (val) return 0
    return 1
}

/** Format the document to send to the client endpoint
 * @constructor
 * @param {object} doc - Document object obtained from the tourplan controller
 */
function format_document(doc) {
    console.log("Formatting document...")
    //  console.log(doc)
    let result = {};
    try {
        if (parseInt(doc.GEN_FACT) === 0) {
            result = {
                "nroCotizacion": doc.nroCotizacion,
                "booking": doc.booking,
                "idTipoDoc": doc.idTipoDoc,
                "fechaServicio": doc.fechaServicio,
                "fechaVence": doc.FechaVence,
                "docIdentidadCli": doc.docIdentidadCli,
                "razonSocialCli": doc.razonSocialCli,
                "textoImp": doc.textoImp,
                "docCounter": `${doc.docCounter};${doc.cotizador};${doc.reserva}`,
                "docVendedor": doc.docVendedor,
                "credito": `${doc.credito}`,
                "idFormaPago": `${doc.idFormaPago}`,
                "subAfecto": doc.subAfecto,
                "subInafecto": parseFloat(doc.subInafecto),
                "docEchoPor": doc.docCounter,
                "listdetalle": [
                    {
                        "idcab": 0,
                        "iddestino": doc.idDestino,
                        "pasajero": doc.pasajero,
                        "idTipoServicio": doc.idTipoServicioImporteLinea,
                        "importe": parseFloat(doc.importeLinea)
                    },
                ]
            }
        } else {
            result = {
                "nroCotizacion": doc.nroCotizacion,
                "booking": doc.booking,
                "idTipoDoc": doc.idTipoDoc,
                "fechaServicio": doc.fechaServicio,
                "fechaVence": doc.FechaVence,
                "docIdentidadCli": doc.docIdentidadCli,
                "razonSocialCli": doc.razonSocialCli,
                "textoImp": doc.textoImp,
                "docCounter": `${doc.docCounter};${doc.cotizador};${doc.reserva}`,
                "docVendedor": doc.docVendedor,
                "credito": `${doc.credito}`,
                "idFormaPago": `${doc.idFormaPago}`,
                "subAfecto": doc.subAfecto,
                "subInafecto": parseFloat(doc.subInafecto),
                "docEchoPor": doc.docCounter,
                "listdetalle": [
                    {
                        "idcab": 0,
                        "iddestino": doc.idDestino,
                        "pasajero": doc.pasajero,
                        "idTipoServicio": doc.idTipoServicioImporteLinea,
                        "importe": parseFloat(doc.importeLinea)
                    },
                    {
                        "idcab": 0,
                        "iddestino": doc.idDestino,
                        "pasajero": doc.pasajero,
                        "idTipoServicio": doc.idTipoServicioUtilidad,
                        "importe": doc.Utilidad
                    }
                ]
            }
        }
    } catch (error) {
        console.log(error);
    }

    return result;
}

/** Format the document to send to the client endpoint
 * @constructor
 * @param {object} data - Document object obtained from the tourplan controller
 */
const sendPostRequest = async (data) => {
    try {
        const endpoint = config.endpoint;
        const response = await axios.post(endpoint, data);

        console.log('Endpoint Response:', response.data);
        return response.data;
    } catch (error) {
        console.error('Endpoint Error:', error.message);
        throw error;
    }
}
