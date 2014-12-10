define(function () {
    "use strict";
        var geocoder = new google.maps.Geocoder();
                function usePointFromPostcode(postcode, callbackFunction) {
                    geocoder.geocode({address: postcode + ", UK"}, function(results, status) {
                            if (results[0]) {
                                callbackFunction(results[0].geometry.location);
                } else {
                    alert("Postcode not found!");
                }
            });
        }
        function createMap(latLong) {
            var mapOptions = {
                center: latLong,
                zoom: 18,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };
            var map = new google.maps.Map(document.getElementById("mapCanvas"), mapOptions);
            var markerOptions = {
                position: latLong,
                map: map
            };
            var marker = new google.maps.Marker(markerOptions);
        }
       
    return function(postCode) {
        usePointFromPostcode(postCode, createMap);
    };
});