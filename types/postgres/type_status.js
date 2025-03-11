export const status = (sequelize, DataTypes) => {
    return sequelize.define('status', {
        id: {
            type: DataTypes.INTEGER,
            allowNull: false,
            primaryKey: true,
        },
        name: {
            type: DataTypes.STRING(100),
            allowNull: true
        }
    }, {
        freezeTableName: true,
        timestamps: true,
        underscored: true
    });

};
