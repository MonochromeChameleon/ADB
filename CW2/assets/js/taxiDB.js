define(["localStorage/db"], function (db) {

    var tables = [
        {
            name: 'jobs',
            primaryKey: 'a'
        }
    ];

    db("taxi", 1, tables);

    return db;
});