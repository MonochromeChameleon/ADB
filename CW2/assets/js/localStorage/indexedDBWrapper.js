define(["lodash"], function (_) {
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
            
            function all(callback) {
                var results = [];
                var store = database.transaction(storename).objectStore(storename);
                store.openCursor().onsuccess = function (e) {
                var cursor = e.target.result;
                    if (cursor) {
                        results.push(cursor.value);
                        cursor.continue();
                    } else {
                        callback(results);
                    }
                };
            }
            
            function clear(callback) {
                var req = database.transaction(storename, "readwrite").objectStore(storename).clear();
                req.onsuccess = function (e) {
                    callback();
                };
            }
            
            function del(key, callback) {
                var req = database.transaction(storename, "readwrite").objectStore(storename).delete(key);
                req.onsuccess = function (e) {
                    callback();
                };
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

            var osWrapper = {
                add: add,
                addAll: addAll,
                all: all,
                clear: clear,
                delete: del,
                get: get
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
            
        };

        req.onupgradeneeded = function (e) {
            _.each(objectStores, function (storeDetails) {
                var objectStore = e.target.result.createObjectStore(storeDetails.name, { keyPath: storeDetails.primaryKey });
                objectStore.createIndex(storeDetails.primaryKey, storeDetails.primaryKey, { unique: true });
            });
        };
    };
});