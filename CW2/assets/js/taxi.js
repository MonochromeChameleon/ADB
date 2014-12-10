define(["jquery", "lodash", "ko", "db", "map", "sync"], function ($, _, ko, db, gMap, sync) {
    "use strict";
    
    var taxiVM = {
        currentJob: ko.computed({
            read: function () {
                return taxiVM.bookings().length ? taxiVM.bookings()[0] : undefined;
            },
            deferEvaluation: true
        }),
        bookings: ko.observableArray(),
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
            db.taxi.payments.add(paymentDetails, function (p) {
                taxiVM.tip(0.0);
                taxiVM.paymentMode(false);
                db.taxi.bookings.delete(p.indexId, sync.update);
            });
        }
    };
    
    sync(taxiVM.bookings);
    
    taxiVM.currentJob.subscribe(function (theJob) {
        if (theJob) {
            gMap(theJob.postCode);
        }
    });
    
    return {
        init: function() {
            ko.applyBindings(taxiVM, $('#mainContent')[0]);
        }
    };
});