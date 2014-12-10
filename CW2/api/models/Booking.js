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
      }
  }
};

