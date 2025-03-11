// Document Definitions

/*
nroCotizacion	char(10)
idTipoDoc	CHAR(4)
fechaServicio	DATE
fechaVence	DATE
docIdentidadCli	CHAR(15)
razonSocialCli	char(100)
textoImp	max
docCounter	CHAR(10)
docVendedor	CHAR(10)
credito	char(1)
idFormaPago	char(2)
subAfecto	real
subInafecto	real
docEchoPor	CHAR(10)
idTipoServicio	char(6)
*/

export const documents = (sequelize, DataTypes) => {
    return sequelize.define('documents', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        nroCotizacion: {
            type: DataTypes.STRING(10),
            allowNull: false,
        },
        fechaServicio: {
            type: DataTypes.DATE,
            allowNull: false
        },
        fechaVence: {
            type: DataTypes.DATE,
            allowNull: false
        },
        docIdentidadCli: {
            type: DataTypes.STRING(15),
            allowNull: false
        },
        razonSocialCli: {
            type: DataTypes.STRING(100),
            allowNull: false
        },
        textoImp: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        docCounter: {
            type: DataTypes.STRING(10),
            allowNull: false
        },
        docVendedor: {
            type: DataTypes.STRING(10),
            allowNull: false
        },
        credito: {
            type: DataTypes.STRING(1),
            allowNull: false
        },
        idFormaPago: {
            type: DataTypes.STRING(2),
            allowNull: false
        },
        subAfecto: {
            type: DataTypes.NUMERIC,
            allowNull: false
        },
        subInafecto: {
            type: DataTypes.NUMERIC,
            allowNull: false
        },
        docEchoPor: {
            type: DataTypes.STRING(10),
            allowNull: false
        },
        idTipoServicio: {
            type: DataTypes.STRING(6),
            allowNull: false
        },
        idDocumento: {
            type: DataTypes.STRING(10),
            allowNull: true
        },
        tipoDoc: {
            type: DataTypes.STRING(4),
            allowNull: true
        },
        serie: {
            type: DataTypes.STRING(5),
            allowNull: true
        },
        correlativo: {
            type: DataTypes.STRING(8),
            allowNull: true
        },
        idTipoServicio: {
            type: DataTypes.STRING(6),
            allowNull: true
        },
        idtarjetaReserva: {
            type: DataTypes.STRING(10),
            allowNull: true
        },
    },
        {
            freezeTableName: true,
            tableName: 'documents',
            timestamps: true,
            underscored: true
        });
};

/* jshint indent: 2 */
export const documents_types = (sequelize, DataTypes) => {
    return sequelize.define('documentTyps', {
        id: {
            type: DataTypes.INTEGER,
            allowNull: false,
            autoIncrement: true,
            primaryKey: true,
        },
        name: {
            type: DataTypes.STRING(100),
            allowNull: true
        },
        last: {
            type: DataTypes.INTEGER,
            allowNull: true
        },
    }, {
        freezeTableName: true,
        timestamps: true,
        underscored: true
    });
};


/*
lista.iddestino	char(3)
lista.pasajero	char(50)
lista.importe	real
*/
export const documents_details = (sequelize, DataTypes) => {
    return sequelize.define('documentDetails', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        iddestino: {
            type: DataTypes.STRING(10),
            allowNull: false,
        },
        pasajero: {
            type: DataTypes.DATE,
            allowNull: false
        },
        importe: {
            type: DataTypes.DATE,
            allowNull: false
        },
    },
        {
            freezeTableName: true,
            tableName: 'documentDetails',
            timestamps: true,
            underscored: true
        });

};