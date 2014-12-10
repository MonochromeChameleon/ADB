define(["lodash",
    "localStorage/webSqlWrapper",
    "localStorage/indexedDBWrapper"], function (_, webSqlWrapper, indexedDBWrapper) {
    "use strict";

    function makeCallCache() {
        var calls = [];
        var ret = {
            applyCache: function (table) {
                _.each(calls, function (call) {
                    table[call.method].apply(table, call.args);
                });
            }
        };

        // Define cache capture methods for all exposed methods on our inner wrapper classes
        _.each(["add", "addAll", "all", "get", "getAll"], function (methodName) {
            ret[methodName] = function () {
                calls.push({
                    method: methodName,
                    args: arguments
                });
            };
        });

        return ret;
    }

    function dbCallCache(tableNames) {
        var cache = {
            applyCache: function (database) {
                // Apply cached calls on each table in the order they were made to the cache.
                _.each(tableNames, function (table) {
                    cache[table].applyCache(database[table]);
                });
            }
        };

        // For each table, we need to construct a cache object.
        _.each(tableNames, function (table) {
            cache[table] = makeCallCache();
        });

        return cache;
    }

    // db is, effectively, a singleton object providing access to any named databases we have created.
    var db = function (dbname, version, tables) {
        var tableNames = _.pluck(tables, 'name');
        
        // Create a temporary wrapper which will capture any calls made to the database before it has been initialized,
        // and then replay those calls with the appropriate arguments upon completion
        db[dbname] = dbCallCache(tableNames);

        // IndexedDB, while supported, is unfathomably slow and buggy on iOS8. Consequently, we should defer to WebSQL
        // where available.
        var openDB = window.openDatabase ? webSqlWrapper : indexedDBWrapper;

        openDB(dbname, version, tables, function (database) {
            // Upon successfully initializing the database, we apply any cached calls, and then replace the cache
            // on our singleton object with the actual database.
            db[dbname].applyCache(database);
            db[dbname] = database;
        });

        // Return our db base object
        return db;
    };

    return db;
});