export const interfaces = (sequelize, DataTypes) => {
    return sequelize.define('interfaces', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        request: {
            type: DataTypes.TEXT,
            allowNull: false,
        },
        response: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        processRounds: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        httpStatus: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        reference: {
            type: DataTypes.STRING(100),
            allowNull: false,
        },
    }, {
        freezeTableName: true,
        tableName: 'interfaces',
        timestamps: true,
        underscored: true
    });
};
