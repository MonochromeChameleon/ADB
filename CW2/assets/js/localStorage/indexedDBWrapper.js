define(["lodash", "loglevel"], function (_, log) {
    "use strict";

    function dbWrapper(database, name) {

        function objectStoreWrapper(storename) {
            var addQueue = [];
            var executing = false;

            function executeAddQueue() {
                if (executing || !addQueue.length) {
                    return;
                }

                executing = true;

                var details = addQueue.shift();

                if (!details.data.length) {
                    // If there's nothing to add, execute the appropriate callback anyway, then carry on with the queue
                    details.callback(details.data);
                    executing = false;
                    setTimeout(executeAddQueue, 0);
                    return;
                }

                // Copy the to-be-added data
                var toAdd = Array.prototype.slice.call(details.data, 0);

                // Open a transaction that will be shared for all the to-be-added items
                var t = database.transaction(storename, "readwrite");
                t.oncomplete = function () {
                    details.callback(details.data);
                };

                t.onerror = function () {
                    details.callback(details.data);
                };

                var store = t.objectStore(storename);

                // Recursively add our items.
                function doAdd() {
                    if (!toAdd.length) {
                        executing = false;
                        setTimeout(executeAddQueue, 0);
                        return;
                    }

                    var datum = toAdd.shift();
                    var req = store.put(datum);
                    req.onsuccess = doAdd;
                }

                doAdd();
            }

            function add(datum, callback) {
                addAll([datum], function () {
                    callback(datum);
                });
            }

            function addAll(data, callback) {
                addQueue.push({
                    data: data,
                    callback: callback
                });
                executeAddQueue();
            }

            function get(key, callback) {
                var req = database.transaction(storename).objectStore(storename).get(key);
                req.onsuccess = function () {
                    callback(req.result);
                };

                req.onerror = function () {
                    callback();
                };
            }

            function getAll(results, tx, keys, callback, notFoundCallback) {
                if (!keys.length) {
                    callback(results);
                    return;
                }

                var keysCopy = Array.prototype.slice.call(keys, 0);

                var key = keysCopy.shift();
                var req = tx.get(key);

                function onResult(result) {
                    if (result) {
                        results.push(result);
                    }
                    getAll(results,tx, keysCopy, callback, notFoundCallback);
                }

                req.onsuccess = function () {
                    if (!req.result && notFoundCallback) {
                        notFoundCallback(key);
                    }
                    onResult(req.result);
                };

                req.onerror = function () {
                    callback(results);
                };
            }

            var osWrapper = {
                add: add,
                addAll: addAll,
                get: get,
                getAll: function (keys, callback, notFoundCallback) {
                    var tx = database.transaction(storename).objectStore(storename);
                    getAll([], tx, keys, callback, notFoundCallback);
                }
            };

            return osWrapper;
        }

        var wrapper = {
            __database: database,
            delete: function (callback) {
                database.close();
                var req = indexedDB.deleteDatabase(name);
                req.onsuccess = function () {
                    callback();
                };
                req.onerror = function () {
                    callback();
                };
                req.onblocked = database.close;
            }
        };

        _.each(database.objectStoreNames, function (objectStore) {
            wrapper[objectStore] = objectStoreWrapper(objectStore);
        });

        return wrapper;
    }

    return function(name, version, objectStores, callback) {
        var req = indexedDB.open(name, version);
        req.onsuccess = function () {
            var database = dbWrapper(this.result, name);
            callback(database);
        };

        req.onerror = function (e) {
            log.error('indexedDB.open: ' + e.target.errorCode);
        };

        req.onupgradeneeded = function (e) {
            _.each(objectStores, function (storeDetails) {
                var objectStore = e.target.result.createObjectStore(storeDetails.name, { keyPath: storeDetails.primaryKey });
                objectStore.createIndex(storeDetails.primaryKey, storeDetails.primaryKey, { unique: true });
            });
        };
    };
});