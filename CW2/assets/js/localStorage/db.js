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

        _.each(["add", "addAll", "get", "getAll"], function (methodName) {
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
                _.each(tableNames, function (table) {
                    cache[table].applyCache(database[table]);
                });
            }
        };

        _.each(tableNames, function (table) {
            cache[table] = makeCallCache();
        });

        return cache;
    }

    var db = function (dbname, version, tables) {
        var tableNames = _.pluck(tables, 'name');
        db[dbname] = dbCallCache(tableNames);

        // IndexedDB, while supported, is unfathomably slow on iOS8. Consequently, we should defer to WebSQL
        // where available.
        var openDB = window.openDatabase ? webSqlWrapper : indexedDBWrapper;

        openDB(dbname, version, tables, function (database) {
            db[dbname].applyCache(database);
            db[dbname] = database;
        });

        return db;
    };

    return db;
});