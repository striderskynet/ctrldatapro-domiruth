export const querys = (sequelize, DataTypes) => {
    return sequelize.define('querys', {
        id: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
        },
        order: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        query: {
            type: DataTypes.TEXT,
            allowNull: true
        }
    }, {
        freezeTableName: true,
        tableName: 'querys',
        timestamps: true,
        underscored: true,
    });
};
