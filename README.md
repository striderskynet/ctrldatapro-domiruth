## TOURPLAN - DOMIRUTH Integration

This is an integration project on ExpressJS for tourPLAN and DOMIRUTH. Executes on a local machine with a NODE/ExpressJS Server, listening by default on PORT 3000. At run import data from a remote tourPLAN server (mssql), process it and writes it to a local Postgres Database, then format the data and send it to a remote EndPoint.

by **CtrlDataPro** / v0.1_stable

## Process

The process evolution explained.

```bash
  - Request booking list from Remote Tourplan Server
  - Verify booking list against "local" database (postgres) and create new if not exists.
  - Format every new booking and send it to the client remote Endpoint.
  - Run Process every 5 minutes.
```

## TODO

-   Cleanup Postgres Database Dump (We do not use QUERYS anymore).
-   Define a Remote tourPLAN Database hostname instead of IP Address, throw DeprecationWarning in Console. **(config.tourplan_db.host)**

## Endpoint

#### View status

```http
  GET / {JSON}
```

```json
  {message: "DOMIRUTH - TOURPLAN INTEGRATION", time: new Date(), zone: process.env.TZ }
```

#### Run process

```http
  GET /run {JSON}
```

```json
  {message: "Executing Integration Process", time: new Date(), zone: process.env.TZ}
```

## Authors

-   [@striderskynet](https://www.github.com/striderskynet)
