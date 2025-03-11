export const errors = (sequelize, DataTypes) => {
    return sequelize.define('errors', {
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
        error: {
            type: DataTypes.TEXT,
            allowNull: false
        },
        statusId: {
            type: DataTypes.INTEGER,
            allowNull: false
        },
    },
        {
            freezeTableName: true,
            tableName: 'errors',
            timestamps: true,
            underscored: true
        });
};