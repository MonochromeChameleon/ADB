/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html
 */

function fakeTimestamp(time) {
    var today = new Date();
    var year = today.getFullYear();
    var month = '0' + (today.getMonth() + 1);
    var day = '0' + today.getDate();
    
    return year + month.substr(month.length - 2) + day.substr(day.length - 2) + time;
}

module.exports.bootstrap = function(cb) {
    
    Booking.create([
        {
            id: 1,
            clientName: 'Rick',
            clientPhoneNumber: '07654321987',
            pickupLocation: "55 Baker Street",
            pickupTime: fakeTimestamp(1315),
            price: 3130,
            postCode: 'W1U 8EW'
        },
        {
            id: 2,
            clientName: 'Carl',
            clientPhoneNumber: '07873642985',
            pickupLocation: "53 Highgate Road",
            pickupTime: fakeTimestamp(1330),
            price: 600,
            postCode: 'NW5 1TL'
        },
        {
            id: 3,
            clientName: "Glenn",
            clientPhoneNumber: "07846899193",
            pickupLocation: "Queen Mary, University of London",
            pickupTime: fakeTimestamp(2030),
            price: 500,
            postCode: 'E1 4NS'
        },
        {
            id: 4,
            clientName: "Maggie",
            clientPhoneNumber: "07690478913",
            pickupLocation: "47 Frith Street",
            pickupTime: fakeTimestamp(1200),
            price: 4140,
            postCode: "W1D 4HT"
        },
        {
            id: 5,
            clientName: "Andrea",
            clientPhoneNumber: "07697086110",
            pickupLocation: "5 Air Street",
            pickupTime: fakeTimestamp(0600),
            price: 3020,
            postCode: "W1J 0AD"
        },
        {
            id: 6,
            clientName: "Eugene",
            clientPhoneNumber: "07293609269",
            pickupLocation: "Science Museum",
            pickupTime: fakeTimestamp(2100),
            price: 2270,
            postCode: "SW7 2DD"
        },
        {
            id: 7,
            clientName: "Michonne",
            clientPhoneNumber: "07822667085",
            pickupLocation: "36 Baker Street",
            pickupTime: fakeTimestamp(2030),
            price: 3820,
            postCode: "W1U 3EU"
        },
        {
            id: 8,
            clientName: "Abraham",
            clientPhoneNumber: "07257131056",
            pickupLocation: "Shoreditch House",
            pickupTime: 1230,
            price: 3160,
            postCode: "E1 6AW"
        }
    ]).exec(cb);
};
