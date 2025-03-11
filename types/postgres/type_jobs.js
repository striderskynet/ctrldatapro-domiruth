export const jobs = (sequelize, DataTypes) => {
    return sequelize.define('jobs', {
        id: {
            type: DataTypes.BIGINT,
            allowNull: false,
            primaryKey: true,
            autoIncrement: true
        },
        begDa: {
            type: DataTypes.DATE,
            allowNull: true
        },
        endDa: {
            type: DataTypes.DATE,
            allowNull: true
        },

    }, {
        freezeTableName: true,
        timestamps: true,
        underscored: true
    });
};
