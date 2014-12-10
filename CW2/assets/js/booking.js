define(["lodash", "ko"], function (_, ko) {
    "use strict";
    
    function constructIndexId(pickupTime, id) {
          // Assume pickupTime is formatted as yyyymmddhhmm
          var paddedId = '00000000' + id;
          
          // indexId is the time, plus the provided booking id, padded to 8 digits  - i.e. we have an identifier which 
          // is strictly ascending with time, regardless of the time at which individual bookings were made (id is 
          // an autoincrementing field on the database), which will only start to overflow after 100 million db entries.
          // At a rate of 2500 bookings per day, this would survive 100 years, which is probably a safe limit.
          return pickupTime + paddedId.substr(paddedId.length - 8);
    }
    
    function formatPickupTime(pickupTime) {
        var tmStr = pickupTime.toString();
        return tmStr.substr(8, 2) + ':' + tmStr.substr(10, 2);
    }
    
    function formatPrice(price) {
        var pStr = price.toString();
        return '£' + pStr.substr(0, pStr.length - 2) + '.' + pStr.substr(pStr.length - 2);
    }
    
    return function (bookingDetails) {
        return {
            indexId: constructIndexId(bookingDetails.pickupTime, bookingDetails.id),
            clientName: bookingDetails.clientName,
            clientPhoneNumber: bookingDetails.clientPhoneNumber,
            pickupLocation: bookingDetails.pickupLocation,
            postCode: bookingDetails.postCode,
            pickupTime: formatPickupTime(bookingDetails.pickupTime),
            price: formatPrice(bookingDetails.price)
        };
    };
});