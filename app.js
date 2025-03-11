import express from 'express';
import cron from 'node-cron';
import config from './config/general.js';
import { send_documents } from './controllers/interface.js';

const PORT = process.env.PORT || config.port;
export var app = express();

/** Routing "default" endpoint for Status Information */
app.get("/", (_, res) => {
    res.json({ message: "DOMIRUTH - TOURPLAN INTEGRATION", time: new Date(), zone: process.env.TZ });
});

/** Routing "/run" endpoint to trigger the Integration Process */
app.get("/run", async (_, res) => {
    res.json({ message: "Executing Integration Process", time: new Date(), zone: process.env.TZ });

    // Execute logic here
    send_documents();

});

/** Listening on port: Default 3000 */
app.listen(PORT, function (err) {
    if (err) console.log('Something went wrong', err)
    else {
        console.log('Server is listening on port: %d, Scheduled to run every %d minutes.', PORT, config.cron);
        console.log('Executing First Load Integration Process in 5 seconds...');
        setTimeout(() => {
            send_documents();
        }, 5000)
    }

});

/**  Scheduling process by node-cron: Default every 5 Min */
cron.schedule(`*/${config.cron} * * * *`, async () => {
    console.log('Executing Scheduled Integration Process');

    // Execute logic here
    send_documents();
});
