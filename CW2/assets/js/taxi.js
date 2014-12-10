define(["jquery", "lodash", "ko", "db", "booking", "map"], function ($, _, ko, db, booking, gMap) {
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
        },
        paymentMode: ko.observable(false),
        tip: ko.observable(0.0),
        takePayment: function () {
            taxiVM.paymentMode(true);
        },
        processPayment: function (tip) {
            // Price has come from our system, so we know the format
            var priceCents = taxiVM.currentJob().price.replace(/[\D]/g,'');
            
            // Tip may be £1 or £1.00 etc., so we need to regularize it before storage
            var tipWithCents = taxiVM.tip() + '.00'; // Ensure there is a decimal point
            var tipValue = tipWithCents.substr(0, tipWithCents.indexOf('.') + 3); // Take two digits after the first decimal point
            var tipCents = tipValue.replace(/[\D]/g,''); // Remove non-digits for a cent input
            
            var paymentDetails = {
                indexId: taxiVM.currentJob().indexId,
                price: priceCents,
                tip: tipCents
            };
            
            // Store the payment details locally and reset the UI
            db.taxi.payments.add(paymentDetails, function () {
                taxiVM.tip(0.0);
                taxiVM.paymentMode(false);
            });
        }
    };
    
    // First load
    taxiVM.refresh();
    
    // Try to update every subsequent minute
    setInterval(taxiVM.refresh, 60000);

    // Load data from the database into our array of active bookings
    db.taxi.bookings.all(taxiVM.bookings);
    
    taxiVM.currentJob.subscribe(function (theJob) {
        gMap(theJob.postCode);
    });
    
    return {
        init: function() {
            ko.applyBindings(taxiVM, $('#mainContent')[0]);
        }
    };
});