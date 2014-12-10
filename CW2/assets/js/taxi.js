define(["jquery", "lodash", "ko", "db", "booking"], function ($, _, ko, db, booking) {
    "use strict";
    
    var apiUrl = '/booking';
    
    var taxiVM = {
        currentJob: ko.computed({
            read: function () {
                return taxiVM.bookings().length ? taxiVM.bookings()[0] : undefined;
            },
            deferEvaluation: true
        }),
        bookings: ko.observableArray(),
        refresh: function () {
            console.log('refresh');
            
            $.ajax({
                type: "GET",
                url: apiUrl,
                data: { },
                success: function (results) {
                    
                    var bookings = _.map(results, booking);
                    db.taxi.bookings.addAll(bookings, function (added) {
                        console.log('Added ' + added.length + ' values');
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
    };
    
    // First load
    taxiVM.refresh();
    
    // Try to update every subsequent minute
    setInterval(taxiVM.refresh, 60000);

    // Load data from the database into our array of active bookings
    db.taxi.bookings.all(taxiVM.bookings);
    
    return {
        init: function() {
            ko.applyBindings(taxiVM, $('#mainContent')[0]);
        }
    };
});