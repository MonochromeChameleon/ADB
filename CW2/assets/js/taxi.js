define(["jquery", "lodash", "ko", "db"], function ($, _, ko, db) {
    "use strict";
    
    var apiUrl = '/booking';
    
    var taxiVM = {
        currentJob: ko.computed(function () {
            return taxiVM.jobs().length ? taxiVM.jobs()[0] : undefined;
        }),
        jobs: ko.observableArray(),
        refresh: function () {
            $.ajax({
                type: "GET",
                url: apiUrl,
                data: { },
                success: function (results) {
                    

                    var returnedFactKeys = _.pluck(results, jsonMapping.JSONKeyFor.FactKey);
                    var missing = _.difference(joinedFactKeys, returnedFactKeys);
                    var fakeFacts = _.map(missing, function (k) {
                        var f = {};
                        f[jsonMapping.JSONKeyFor.FactKey] = k;
                        f['_'] = 1;
                        return f;
                    });

                    var toReturn = [].concat(results).concat(fakeFacts);
                    callback(toReturn);
                },
                error: commsErrorHandler.handleError,
                // Serialize arrays in a format the server understands.
                dataType: "json",
                traditional: true
            });
        }
    };
    
    return {
        init: function() {
            ko.applyBindings(taxiVM, $('#mainContent')[0]);
        }
    };
});