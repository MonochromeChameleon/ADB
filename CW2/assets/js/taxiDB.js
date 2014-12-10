define(["localStorage/db"], function (db) {

    var tables = [
        {
            name: 'bookings',
            primaryKey: 'indexId'
        },
        {
            name: 'payments',
            primaryKey: 'indexId'
        }
    ];

    db("taxi", 1, tables);

    return db;
});