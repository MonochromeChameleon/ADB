/**
 * BookingController
 *
 * @description :: Server-side logic for managing bookings
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
    paid: function(req, res) {
        // Dummy method stub to just remove the booking from our bootstrapped data.
        // In a real application, we would obviously record the payment etc. and hence
        // use the fact that the job was complete to remove it from the data feed.
        Booking.destroy({ id: req.param('id') }).exec(function deleteCB(err){
            if (err) {
                res.status(500);
                return res.send('Error!');
            }

            res.status(200);
            return res.send();
        });
    }
};

