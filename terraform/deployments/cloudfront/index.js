'use strict';

exports.handler = (event, context, callback) => {
    console.log('Event: ', JSON.stringify(event, null, 2));
    console.log('Context: ', JSON.stringify(context, null, 2));
    var request = event.Records[0].cf.request;
    var requestUrl = request.uri;

    var regex_ext = "^([^#\\?]+)\\.(atom|chm|css|csv|diff|doc|docx|dot|dxf|eps|gif|gml|html|ico|ics|jpeg|jpg|JPG|js|json|kml|odp|ods|odt|pdf|PDF|png|ppt|pptx|ps|rdf|rtf|sch|txt|wsdl|xls|xlsm|xlsx|xlt|xml|xsd|xslt|zip)([\\?#]+.*)?$";
    var regex_html = "^[^#\\?]+([\\?#]+.*)?$";
    var regex_root = "^\/(.+)"

    // Replace multiple slashes
    var redirectUrl = requestUrl.replace(/([^:])\/\/+/g,'$1/');

    // Requests without document extension, rewrite adding .html
    if ((redirectUrl.match(regex_ext) == null) &&  (redirectUrl.match(regex_root) != null)){
            var match_html = redirectUrl.match(regex_html);
            redirectUrl =  [match_html[1], '.html', match_html[2]].join('');
    }

request.uri = redirectUrl;
return callback(null, request);
};