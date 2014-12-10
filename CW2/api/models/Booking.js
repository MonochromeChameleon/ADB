/**
* Booking.js
*
* @description :: TODO: You might write a short summary of how this model works and what it represents here.
* @docs        :: http://sailsjs.org/#!documentation/models
*/

module.exports = {

  attributes: {
      id: {
          type: 'integer',
          require: true
      },
      clientName: {
          type: 'string',
          required: true
      },
      clientPhoneNumber: {
          type: 'string',
          required: true
      },
      pickupLocation: {
          type: 'string',
          required: true
      },
      pickupTime: {
          type: 'integer',
          required: true
      },
      price: {
          type: 'integer',
          required: true
      },
      
      // Not in the original data feed - should be added to allow mapping
      postCode: {
          type: 'string',
          required: true
      },
      
      getIndexId: function () {
          // Assume pickupTime is formatted as yyyymmddhhmm
          var paddedId = '00000000' + this.id;
          
          // indexId is the time, plus the provided booking id, padded to 8 digits  - i.e. we have an identifier which 
          // is strictly ascending with time, regardless of the time at which individual bookings were made (id is 
          // an autoincrementing field on the database), which will only start to overflow after 100 million db entries.
          // At a rate of 2500 bookings per day, this would survive 100 years, which is probably a safe limit.
          return this.pickupTime + ' ' + paddedId.substr(paddedId.length - 8);
      }
  }
};

