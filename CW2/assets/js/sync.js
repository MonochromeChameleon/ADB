define(["jquery", "lodash", "db", "booking"], function ($, _, db, booking) {
    "use strict";
    
    var bookingsObservable;
    var apiUrl = '/booking';
    
    function refreshBookings() {
        // Bail out early if we're not online
        if (!navigator.onLine) {
            return;
        }
        
        $.ajax({
            type: "GET",
            url: apiUrl,
            data: { },
            success: function (results) {
                var bookings = _.map(results, booking);
                // Flush storage and repopulate with the new values
                db.taxi.bookings.clear(function () {
                    db.taxi.bookings.addAll(bookings, sync.update);                
                });
            },
            error: function () {
                // ignore for now
            },
            // Serialize arrays in a format the server understands.
            dataType: "json",
            traditional: true
        });
    }
    
    function syncPayments(payments) {
        
        // Don't refresh the bookings unless our payments are synced up first.
        // This is something of an implementation kludge to allow for our stubbed out API
        if (!payments.length) {
            refreshBookings();
            return;
        }
        
        // Bail out early if we're not online
        if (!navigator.onLine) {
            return;
        }
        
        var pmnt = payments.shift();
        var id = pmnt.indexId.substr(pmnt.indexId.length - 8);

        $.ajax({
            type: "POST",
            url: apiUrl + '/' + id + '/paid',
            data: { },
            success: function (results) {
                // If we have successfully synced with the database, we can delete the payment from our local 
                // cache
                db.taxi.payments.delete(pmnt.indexId, function () {
                    // And then handle the rest of the queue
                    syncPayments(payments);
                });
            },
            error: function () {
                // ignore for now
            },
            traditional: true
        });
    }
    
    function synchronize() {
        db.taxi.payments.all(syncPayments);
    }
    
    var sync = function (observable) {
        bookingsObservable = observable;
        
        // First load
        synchronize();
        
        // Try to update every subsequent minute
        setInterval(synchronize, 60000);
    };
    
    sync.update = function () {
        // Load data from the database into our array of active bookings
        db.taxi.bookings.all(bookingsObservable);
    };
    
    return sync;
});