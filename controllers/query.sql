WITH BASE AS (
        SELECT
                a.TRH_ID,
                trim(a.REFERENCE) REFERENCE,
                b.FULL_REFERENCE,
                a.ENTERED_DATE,
                b.NAME,
                b.STATUS,
                b.TRAVELDATE "fechaServicio",
                b.LAST_SERVICE_DATE "fechaFinal",
                b.AGENT,
                (SELECT REPLACE(DA1.DESCRIPTION,' ','')  FROM DA1 WHERE DA1.CODE = (SELECT DRM.ANALYSIS_MASTER1 FROM DRM WHERE DRM.CODE = b.AGENT)) VENDEDOR_RAW,
                 (SELECT top 1 TRL.PAYMENT_DUE FROM TRL WHERE TRL.TRH_ID = a.TRH_ID ) "FechaVence",
                ISNULL((SELECT CASE WHEN a.FAX IS NULL OR a.FAX = '' THEN 'N/D' ELSE a.FAX END
                        FROM TPU a
                        JOIN CSL c on c.NAME = a.FULLNAME
                        WHERE c.INITIALS = b.CONSULTANT ),'N/D') CONSULTANT_DNI,
                ISNULL((SELECT CASE WHEN a.FAX IS NULL OR a.FAX = '' THEN 'N/D' ELSE a.FAX END
                        FROM TPU a WHERE TRIM(REPLACE(REPLACE(a.FULLNAME , NCHAR(0x0020), ''), NCHAR(160), '') ) = (  SELECT REPLACE(DA1.DESCRIPTION,' ','')  FROM DA1 WHERE DA1.CODE = (SELECT DRM.ANALYSIS_MASTER1 FROM DRM WHERE DRM.CODE = b.AGENT) ) ),'N/D') VENDEDOR_DNI,
                db3.DESCRIPTION TipoDoc,
                case db3.DESCRIPTION when 'Factura' THEN '01' WHEN 'Boleta' THEN '03' ELSE 'N/D' END "idTipoDoc",
                CASE WHEN b.AGENT in('DOMIRU','DIRNAT') THEN (select TRIM(CONCAT(p.PAX_FORENAME, ' ', p.PAX_SURNAME ))  from PXN p where p.PXN_ID = (SELECT top 1 x.PXN_ID  from PNB x WHERE  x.BHD_ID = b.BHD_ID and x.LEADPAX = 1 )) ELSE  (SELECT d.NAME  FROM DRM d WHERE d.CODE = b.AGENT ) END "razonSocialCli",
                CASE WHEN b.AGENT in('DOMIRU','DIRNAT') THEN (select  p.NOTES10  from PXN p where p.PXN_ID = (SELECT top 1 x.PXN_ID  from PNB x WHERE  x.BHD_ID = b.BHD_ID and x.LEADPAX = 1 )) ELSE  (SELECT d.ADDRESS5  FROM DRM d WHERE d.CODE = b.AGENT ) END "docIdentidadCli",
                CASE b.STATUS WHEN 'AP' THEN 0 WHEN 'AC' THEN 1 ELSE -1 END credito,
                29 "idFormaPago",
                isnull(( SELECT top 1 t.FAX  FROM TPU t where t.FULLNAME = (select TOP 1 s.DESCRIPTION  from SA4 s where s.CODE = b.SALE4 ) ), 'N/D') "docCounter",
                isnull(TPU.FAX,'N/D')"docEchoPor",
                (SELECT top 1 b.TRANSACTION_ITEM  FROM TRL b WHERE b.TRH_ID = a.TRH_ID ) BK_REFERENCE,
                CASE OPT.ANALYSIS4 WHEN 'EX' THEN bsd.cost-bsd.COSTTAX ELSE 0 END Exportacion,
                CASE OPT.ANALYSIS4 WHEN 'NE' THEN bsd.cost-bsd.COSTTAX ELSE 0  END Intangibles,
                BSD.COSTTAX IgvCosto,
                CASE OPT.ANALYSIS4 WHEN 'EX' THEN bsd.AGENT-bsd.AGENT_TAX ELSE 0 END + CASE OPT.ANALYSIS4 WHEN 'NE' THEN bsd.AGENT-bsd.AGENT_TAX ELSE 0  END + BSD.AGENT_TAX TotalVenta,
        trim( b.CONSULTANT) "cotizador",
        trim(b.SALE1) "reserva"
        FROM
                TRH a
                INNER JOIN BHD b on b.FULL_REFERENCE = (SELECT top 1 b.TRANSACTION_ITEM  FROM TRL b WHERE b.TRH_ID = a.TRH_ID )
                INNER JOIN BSL bsl on bsl.BHD_ID = b.BHD_ID
                join opt on opt.opt_id = bsl.opt_id
                join srv on srv.code = opt.service
                join crm on crm.code = opt.supplier
                join db3 on db3.code = opt.ANALYSIS3
                join db4 on db4.code = opt.ANALYSIS4
                join loc on loc.CODE = opt.LOCATION
                join bsd on bsd.BSL_ID = bsl.BSL_ID
                LEFT JOIN TPU ON TPU.NAME = a.ENTERED_BY
        where
                a.LEDGER = 'R'--'P'
                and a.TRAN_TYPE = 1
                and a.ENTERED_DATE >= '2024-01-09'
                AND b.STATUS IN ('AP','AC')
                --and a.REFERENCE = '10119'--'10037'
),
DOCUMENTS AS ( SELECT
        REFERENCE "nroCotizacion",
        FULL_REFERENCE "booking",
        CASE WHEN MONTH("ENTERED_DATE") = MONTH("fechaFinal") THEN 1 ELSE 0 END GEN_FACT,
        idTipoDoc,
        "fechaServicio",
        "fechaFinal",
        "FechaVence",
        "docIdentidadCli",
        "razonSocialCli",
        CASE credito when 1 then '000984' ELSE '000013' END "docCounter",
        VENDEDOR_DNI "docVendedor",
        credito,
        CASE credito when 1 then 2 ELSE "idFormaPago" END "idFormaPago",
        'LIM' "idDestino",
        NAME "pasajero",
        0 "subAfecto",
--      case "idTipoDoc" when '01' THEN  "Exportacion" WHEN '03' THEN Intangibles + "IgvCosto" END  "importe",
        SUM("TotalVenta") OVER(PARTITION BY REFERENCE) AS TotalVentaDoc,
        case "idTipoDoc" when '01' THEN  sum("Exportacion") OVER(PARTITION BY REFERENCE)  WHEN '03'
        THEN sum("Intangibles")OVER(PARTITION BY REFERENCE) + sum("IgvCosto")OVER(PARTITION BY REFERENCE) END  "importeLinea",
        sum("Exportacion") OVER(PARTITION BY REFERENCE) + sum("Intangibles")OVER(PARTITION BY REFERENCE) + sum("IgvCosto")OVER(PARTITION BY REFERENCE)  "totalCosto",
    "cotizador",
    "reserva"
FROM
        BASE
),
FACTS_BOLETA AS (
SELECT
        "nroCotizacion",
        booking,
        GEN_FACT,
        idTipoDoc,
        "fechaServicio",
        "FechaVence",
        "docIdentidadCli",
        "razonSocialCli",
        case idTipoDoc
        WHEN '01' THEN CONCAT( "pasajero",' T/TARJETA SS ', FORMAT("fechaServicio",'dd'),REPLACE(UPPER(FORMAT(fechaServicio,'MMM','es-ES')),'.',''), '/' ,FORMAT("fechaFinal",'dd'), REPLACE(UPPER(FORMAT("fechaFinal",'MMM','es-ES')),'.',''),' SERVICIOS DE EXPORTACION DEL PAQUETE TURISTICO CONSUMIDO EN EL PERU, A FAVOR DE NUESTRO CLIENTE OPERADOR TURISTICO DEL EXTERIOR QUE COMPRENDE TRANSP. TERRESTRE.FERROVIARIO/ALIMENTACION/TRASLADOS.')
        WHEN '03' THEN CONCAT( "pasajero",' T/TARJETA SS ', FORMAT("fechaServicio",'dd'),REPLACE(UPPER(FORMAT(fechaServicio,'MMM','es-ES')),'.',''), '/' ,FORMAT("fechaFinal",'dd'), REPLACE(UPPER(FORMAT("fechaFinal",'MMM','es-ES')),'.',''),' POR LOS SERVICIOS INTANGIBLES DE ORGANIZACIÓN DEL PRESENTE PAQUETE TURISTICO CONSUMIDO EN EL PERU, A FAVOR DE NUESTRO CLIENTE OPERADOR TURISTICO DEL EXTERIOR')
        ELSE '' END "textoImp",
        "docCounter",
        "docVendedor",
        credito,
        "idFormaPago",
        "subAfecto",
        round("TotalVentaDoc" * ROUND(importeLinea / totalCosto * 100, 2) / 100,2) "subInafecto",
        "idDestino",
        "pasajero",
--      "TotalVentaDoc",
        case idTipoDoc WHEN '01' then '00280' when '03' THEN '00007' ELSE 'N/D' END "idTipoServicioImporteLinea",
        round("importeLinea",2)"importeLinea",
--      "totalCosto",
        --importeLinea,
        ROUND(importeLinea / totalCosto * 100, 2) "margenPorc",
        case idTipoDoc WHEN '01' then '00296' when '03' THEN '00297' ELSE 'N/D' END "idTipoServicioUtilidad",
        round(("TotalVentaDoc" * ROUND(importeLinea / totalCosto * 100, 2) / 100) - ROUND("importeLinea",2),2)  "Utilidad",
    "cotizador",
    "reserva"
FROM
        DOCUMENTS
WHERE GEN_FACT = 1
GROUP BY
        "nroCotizacion",
        booking,
        GEN_FACT,
        idTipoDoc,
        "fechaServicio",
        "FechaVence",
        "docIdentidadCli",
        "razonSocialCli",
        "docCounter",
        "docVendedor",
        credito,
        "idFormaPago",
        "idDestino",
        "pasajero",
        "subAfecto",
        "TotalVentaDoc",
        "importeLinea",
        "totalCosto",
        "fechaFinal",
    "cotizador",
    "reserva"
),
BASE2 AS (
        SELECT
                a.TRH_ID,
                TRL.TRL_ID,
                bsl.BSL_ID ,
                opt.OPT_ID,
                opt.SERVICE,
                opt.DESCRIPTION,
           -- ISNULL((select TOP 1 TRL_ID FROM TRL WHERE TRL.TRH_ID= a.TRH_ID AND TRL.BSL_ID = bsl.BSL_ID),0) trlId,
                trim(a.REFERENCE) REFERENCE,
                b.FULL_REFERENCE,
                a.ENTERED_DATE,
                b.NAME,
                b.STATUS,
                b.TRAVELDATE "fechaServicio",
                b.LAST_SERVICE_DATE "fechaFinal",
                b.AGENT,
                (SELECT REPLACE(DA1.DESCRIPTION,' ','')  FROM DA1 WHERE DA1.CODE = (SELECT DRM.ANALYSIS_MASTER1 FROM DRM WHERE DRM.CODE = b.AGENT)) VENDEDOR_RAW,
                 (SELECT top 1 TRL.PAYMENT_DUE FROM TRL WHERE TRL.TRH_ID = a.TRH_ID ) "FechaVence",
                ISNULL((SELECT CASE WHEN a.FAX IS NULL OR a.FAX = '' THEN 'N/D' ELSE a.FAX END
                        FROM TPU a
                        JOIN CSL c on c.NAME = a.FULLNAME
                        WHERE c.INITIALS = b.CONSULTANT ),'N/D') CONSULTANT_DNI,
                ISNULL((SELECT CASE WHEN a.FAX IS NULL OR a.FAX = '' THEN 'N/D' ELSE a.FAX END
                        FROM TPU a WHERE TRIM(REPLACE(REPLACE(a.FULLNAME , NCHAR(0x0020), ''), NCHAR(160), '') ) = (  SELECT REPLACE(DA1.DESCRIPTION,' ','')  FROM DA1 WHERE DA1.CODE = (SELECT DRM.ANALYSIS_MASTER1 FROM DRM WHERE DRM.CODE = b.AGENT) ) ),'N/D') VENDEDOR_DNI,
                db3.DESCRIPTION TipoDoc,
                case db3.DESCRIPTION when 'Factura' THEN '01' WHEN 'Boleta' THEN '03' ELSE 'N/D' END "idTipoDoc",
                CASE WHEN b.AGENT in('DOMIRU','DIRNAT') THEN (select TRIM(CONCAT(p.PAX_FORENAME, ' ', p.PAX_SURNAME ))  from PXN p where p.PXN_ID = (SELECT top 1 x.PXN_ID  from PNB x WHERE  x.BHD_ID = b.BHD_ID and x.LEADPAX = 1 )) ELSE  (SELECT d.NAME  FROM DRM d WHERE d.CODE = b.AGENT ) END "razonSocialCli",
                CASE WHEN b.AGENT in('DOMIRU','DIRNAT') THEN (select  p.NOTES10  from PXN p where p.PXN_ID = (SELECT top 1 x.PXN_ID  from PNB x WHERE  x.BHD_ID = b.BHD_ID and x.LEADPAX = 1 )) ELSE  (SELECT d.ADDRESS5  FROM DRM d WHERE d.CODE = b.AGENT ) END "docIdentidadCli",
                CASE b.STATUS WHEN 'AP' THEN 0 WHEN 'AC' THEN 1 ELSE -1 END credito,
                29 "idFormaPago",
                isnull(( SELECT top 1 t.FAX  FROM TPU t where t.FULLNAME = (select TOP 1 s.DESCRIPTION  from SA4 s where s.CODE = b.SALE4 ) ), 'N/D') "docCounter",
                isnull(TPU.FAX,'N/D')"docEchoPor",
                (SELECT top 1 b.TRANSACTION_ITEM  FROM TRL b WHERE b.TRH_ID = a.TRH_ID ) BK_REFERENCE,
                CASE OPT.ANALYSIS4 WHEN 'EX' THEN bsd.cost-bsd.COSTTAX ELSE 0 END Exportacion,
                CASE OPT.ANALYSIS4 WHEN 'NE' THEN bsd.cost-bsd.COSTTAX ELSE 0  END Intangibles,
                BSD.COSTTAX IgvCosto,
                --CASE OPT.ANALYSIS4 WHEN 'EX' THEN bsd.AGENT-bsd.AGENT_TAX ELSE 0 END + CASE OPT.ANALYSIS4 WHEN 'NE' THEN bsd.AGENT-bsd.AGENT_TAX ELSE 0  END + BSD.AGENT_TAX TotalVenta
                TRL.TRANSACTION_VALUE TotalVenta,
        trim(b.CONSULTANT) "cotizador",
        trim(b.SALE1) "reserva"
        FROM
                TRH a
                INNER JOIN BHD b on b.FULL_REFERENCE = (SELECT top 1 b.TRANSACTION_ITEM  FROM TRL b WHERE b.TRH_ID = a.TRH_ID )
                INNER JOIN BSL bsl on bsl.BHD_ID = b.BHD_ID --and bsl.BSL_ID in (select TRL.BSL_ID from TRL WHERE TRL.TRH_ID = a.TRH_ID AND TRL.LINE_CATEGORY = 'FRV')
                join opt on opt.opt_id = bsl.opt_id
                join srv on srv.code = opt.service
                join crm on crm.code = opt.supplier
                join db3 on db3.code = opt.ANALYSIS3
                join db4 on db4.code = opt.ANALYSIS4
                join loc on loc.CODE = opt.LOCATION
                join bsd on bsd.BSL_ID = bsl.BSL_ID
                LEFT JOIN TPU ON TPU.NAME = a.ENTERED_BY
                LEFT JOIN TRL ON TRL.TRH_ID = a.TRH_ID and trl.BSL_ID = bsl.BSL_ID and trl.TRANSACTION_ITEM = B.FULL_REFERENCE AND TRL.LINE_CATEGORY IN('VAL','TAX') AND TRL.DEBIT_ACCOUNT ='050000'
        where --B.FULL_REFERENCE = 'BKFI100098' and
                a.LEDGER = 'R'--'P'
                and a.TRAN_TYPE = 1
            and a.ENTERED_DATE >= '2024-01-09'
                AND b.STATUS IN ('AP','AC')
          --and a.REFERENCE = '10119'--'10037'
),
DOCUMENTS2 AS ( SELECT
        REFERENCE "nroCotizacion",
        FULL_REFERENCE "booking",
        CASE WHEN MONTH("ENTERED_DATE") = MONTH("fechaFinal") THEN 1 ELSE 0 END GEN_FACT,
        '03' idTipoDoc,
        "fechaServicio",
        "fechaFinal",
        "FechaVence",
        "docIdentidadCli",
        "razonSocialCli",
        CASE credito when 1 then '000984' ELSE '000013' END "docCounter",
        VENDEDOR_DNI "docVendedor",
        credito,
        CASE credito when 1 then 2 ELSE "idFormaPago" END "idFormaPago",
        'LIM' "idDestino",
        NAME "pasajero",
        0 "subAfecto",
--      case "idTipoDoc" when '01' THEN  "Exportacion" WHEN '03' THEN Intangibles + "IgvCosto" END  "importe",
        SUM("TotalVenta") OVER(PARTITION BY REFERENCE) AS TotalVentaDoc,
        case "idTipoDoc" when '01' THEN  sum("Exportacion") OVER(PARTITION BY REFERENCE)  WHEN '03'
        --THEN sum("Intangibles")OVER(PARTITION BY REFERENCE) + sum("IgvCosto")OVER(PARTITION BY REFERENCE) END  "importeLinea",
        THEN sum("TotalVenta") OVER(PARTITION BY REFERENCE) END  "importeLinea",
        sum("Exportacion") OVER(PARTITION BY REFERENCE) + sum("Intangibles")OVER(PARTITION BY REFERENCE) + sum("IgvCosto")OVER(PARTITION BY REFERENCE)  "totalCosto",
    "cotizador",
    "reserva"
FROM
        BASE2
),
BOLETAS AS ( SELECT DISTINCT
        "nroCotizacion",
        booking,
        GEN_FACT,
        idTipoDoc,
        "fechaServicio",
        "FechaVence",
        "docIdentidadCli",
        "razonSocialCli",
        case idTipoDoc
        WHEN '01' THEN CONCAT( "pasajero",' T/TARJETA SS ', FORMAT("fechaServicio",'dd'),REPLACE(UPPER(FORMAT(fechaServicio,'MMM','es-ES')),'.',''), '/' ,FORMAT("fechaFinal",'dd'), REPLACE(UPPER(FORMAT("fechaFinal",'MMM','es-ES')),'.',''),' ANTICIPO POR SERVICIOS DE  EXPORTACION DEL PAQUETE TURISTICO CONSUMIDO EN EL PERU,  POR  NUESTRO CLIENTE OPERADOR TURISTICO DEL EXTERIOR')
        WHEN '03' THEN CONCAT( "pasajero",' T/TARJETA SS ', FORMAT("fechaServicio",'dd'),REPLACE(UPPER(FORMAT(fechaServicio,'MMM','es-ES')),'.',''), '/' ,FORMAT("fechaFinal",'dd'), REPLACE(UPPER(FORMAT("fechaFinal",'MMM','es-ES')),'.',''),' ANTICIPO POR SERVICIOS DE  EXPORTACION DEL PAQUETE TURISTICO CONSUMIDO EN EL PERU,  POR  NUESTRO CLIENTE OPERADOR TURISTICO DEL EXTERIOR')
        ELSE '' END "textoImp",
        "docCounter",
        "docVendedor",
        credito,
        "idFormaPago",
        "subAfecto",
        TotalVentaDoc subInafecto,-- round("TotalVentaDoc" * ROUND(importeLinea / totalCosto * 100, 2) / 100,2) "subInafecto",
        "idDestino",
        "pasajero",
--      "TotalVentaDoc",
        case idTipoDoc WHEN '01' then '00280' when '03' THEN '00007' ELSE 'N/D' END "idTipoServicioImporteLinea",
        TotalVentaDoc "importeLinea",
--      "totalCosto",
        --importeLinea,
        0 "margenPorc",
        case idTipoDoc WHEN '01' then '00296' when '03' THEN '00297' ELSE 'N/D' END "idTipoServicioUtilidad",
        0 "Utilidad",
    "cotizador",
    "reserva"
FROM
        DOCUMENTS2
WHERE GEN_FACT = 0
GROUP BY
        nroCotizacion,booking,GEN_FACT,idTipoDoc,fechaServicio,fechaFinal,FechaVence,docIdentidadCli,razonSocialCli,docCounter,docVendedor,credito,idFormaPago,idDestino,pasajero,subAfecto,TotalVentaDoc,importeLinea,totalCosto,cotizador,reserva
        ),
BOLETAS_ADELANTO AS (
                SELECT
        nroCotizacion,
        booking,
        GEN_FACT,
        idTipoDoc,
        fechaServicio,
        FechaVence,
        docIdentidadCli,
        razonSocialCli,
        textoImp,
        docCounter,
        docVendedor,
        credito,
        idFormaPago,
        sum(subAfecto) subAfecto,
        sum(subInafecto) subInafecto,
        idDestino,
        pasajero,
        idTipoServicioImporteLinea,
        sum(subInafecto)importeLinea,
        null margenPorc,
        null idTipoServicioUtilidad,
        null Utilidad,
    cotizador,
    reserva
FROM
        BOLETAS
group by nroCotizacion, booking,
        GEN_FACT,
        idTipoDoc,
        fechaServicio,
        FechaVence,
        docIdentidadCli,
        razonSocialCli,
        textoImp,
        docCounter,
        docVendedor,
        credito,
        idFormaPago,
        idDestino,
        pasajero,
        idTipoServicioImporteLinea,
    cotizador,
    reserva
        )
SELECT * FROM FACTS_BOLETA
UNION ALL
SELECT * FROM BOLETAS_ADELANTO