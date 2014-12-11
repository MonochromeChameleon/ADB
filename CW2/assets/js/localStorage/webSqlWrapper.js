define(["lodash"], function (_) {
    "use strict";

    function dbWrapper(database, tables) {

        function tableWrapper(table) {

            function add(datum, callback) {
                addAll([datum], function () {
                    callback(datum); // On completion, callback with the added item
                });
            }

            function addAll(data, callback) {
                database.transaction(function (tx) {
                    _.each(data, function (datum) {
                        tx.executeSql('INSERT OR REPLACE INTO ' + table.name + ' (pk, value) VALUES (?, ?)', [datum[table.primaryKey], JSON.stringify(datum)]);
                    });

                    // Call back with the original data
                    callback(data);
                });
            }
            
            function all(callback) {
                database.transaction(function (tx) {
                    tx.executeSql('SELECT * FROM ' + table.name + ' ORDER BY pk ASC', [], function (tx, sqlResult) {
                        var results = [];
                        for (var ix = 0; ix < sqlResult.rows.length; ix += 1) { // We can't use a smart iterator here because it's not an array
                            results.push(JSON.parse(sqlResult.rows.item(ix).value));
                        }
                        callback(results);
                    });
                });
            }
            
            function clear(callback) {
                database.transaction(function (tx) {
                    tx.executeSql('DELETE FROM ' + table.name, [], function (tx) {
                        callback();
                    });
                });
            }
            
            function del(key, callback) {
                database.transaction(function (tx) {
                    tx.executeSql('DELETE FROM ' + table.name + ' WHERE pk = ?', [key], function (tx) {
                        callback();
                    });
                });
            }

            function get(key, callback) {
                database.transaction(function (tx) {
                    tx.executeSql('SELECT * FROM ' + table.name + ' WHERE pk = ?', [key], function (tx, results) {
                        if (results.rows.length) { // It's a primary key, so guaranteed only one result
                            var res = JSON.parse(results.rows.item(0).value);
                            callback(res);
                        } else {
                            callback();
                        }
                    });
                });
            }

            function getAll(results, keys, callback, notFoundCallback) {
                if (!keys.length) {
                    // If we're done, pass the results back to the calling function.
                    callback(results);
                    return;
                }

                var keysCopy = Array.prototype.slice.call(keys, 0);

                // We have to batch the request as it slows down markedly for too many items being retrieved
                var keySlice = _.take(keysCopy, 500);
                var keysLeft = _.drop(keysCopy, 500);

                var foundKeys = [];
                var qs = [];
                _.times(keySlice.length, function () {
                    qs.push('?');
                });

                database.transaction(function (tx) {
                    var query = 'SELECT * FROM ' + table.name + ' WHERE pk IN (' + qs.join(',') + ')';
                    tx.executeSql(query, keySlice, function (tx, sqlResult) {
                        for (var ix = 0; ix < sqlResult.rows.length; ix += 1) { // We can't use a smart iterator here because it's not an array
                            results.push(JSON.parse(sqlResult.rows.item(ix).value));
                            foundKeys.push(sqlResult.rows.item(ix).pk);
                        }

                        if (notFoundCallback) {
                            var missingResults = _.difference(keys, foundKeys);
                            _.each(missingResults, function (key) {
                                notFoundCallback(key);
                            });
                        }

                        // Process the next batch
                        getAll(results, keysLeft, callback, notFoundCallback);
                    });
                });
            }

            return {
                add: add,
                addAll: addAll,
                all: all,
                clear: clear,
                delete: del,
                get: get,
                getAll: function (keys, callback, notFoundCallback) {
                    getAll([], keys, callback, notFoundCallback);
                }
            };
        }

        function deleteTable(tables, tx, callback) {
            if (!tables.length) {
                callback();
                return;
            }

            var table = tables.shift();
            tx.executeSql('DROP TABLE ' + table.name, [], function () {
                deleteTable(tables, tx, callback);
            });
        }

        var wrapper = {
            __database: database,
            delete: function (callback) {
                var tablesCopy = Array.prototype.slice.call(tables, 0);
                database.transaction(function (tx) {
                    deleteTable(tablesCopy, tx, callback);
                });
            }
        };

        _.each(tables, function (table) {
            wrapper[table.name] = tableWrapper(table);
        });

        return wrapper;
    };

    function createTables(tables, tx, callback) {
        if (!tables.length) {
            callback();
            return;
        }
        var tablesCopy = Array.prototype.slice.call(tables, 0);
        var table = tablesCopy.shift();
        // Default our schema to a basic key/value one
        tx.executeSql('CREATE TABLE IF NOT EXISTS ' + table.name + '( pk VARCHAR (40) NOT NULL PRIMARY KEY, value TEXT)', [], function () {
            createTables(tablesCopy, tx, callback);
        });
    }

    return function(name, version, tables, callback) {
        var database = openDatabase(name, version, name, 50 * 1024 * 1024); // Request 50MB
        database.transaction(function (tx) {
            createTables(tables, tx, function () {
                var db = dbWrapper(database, tables);
                callback(db);
            });
        });
    };
});