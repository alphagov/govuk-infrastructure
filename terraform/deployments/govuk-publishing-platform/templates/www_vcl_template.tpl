backend origin {
    .connect_timeout = 5s;
    .dynamic = true;
    .port = "443";
    .host = "${origin_hostname}";
    .first_byte_timeout = 15s;
    .max_connections = 200;
    .between_bytes_timeout = 10s;
    .ssl = true;
    .ssl_check_cert = always;
    .min_tls_version = "1.2";
    .ssl_ciphers = "ECDHE-RSA-AES256-GCM-SHA384";
    .ssl_cert_hostname = "${origin_hostname}";
    .ssl_sni_hostname = "${origin_hostname}";

    .probe = {
        .request =
            "HEAD / HTTP/1.1"
            "Host: ${origin_hostname}"
            "User-Agent: Fastly healthcheck"
%{ if basic_authentication_encoded_secret != "" ~}
            "Authorization: Basic ${basic_authentication_encoded_secret}"
%{ endif ~}
            "Connection: close";
        .threshold = 1;
        .window = 2;
        .timeout = 5s;
        .initial = 1;
        .expected_response = 200;
        .interval = 10s;
    }
}


acl purge_ip_allowlist {
  "23.235.32.0"/20;   # Fastly cache node
  "43.249.72.0"/22;   # Fastly cache node
  "103.244.50.0"/24;  # Fastly cache node
  "103.245.222.0"/23; # Fastly cache node
  "103.245.224.0"/24; # Fastly cache node
  "104.156.80.0"/20;  # Fastly cache node
  "151.101.0.0"/16;   # Fastly cache node
  "157.52.64.0"/18;   # Fastly cache node
  "172.111.64.0"/18;  # Fastly cache node
  "185.31.16.0"/22;   # Fastly cache node
  "199.27.72.0"/21;   # Fastly cache node
  "199.232.0.0"/16;   # Fastly cache node
  "202.21.128.0"/24;  # Fastly cache node
  "203.57.145.0"/24;  # Fastly cache node
  "167.82.0.0"/17;    # Fastly cache node
  "167.82.128.0"/20;  # Fastly cache node
  "167.82.160.0"/20;  # Fastly cache node
  "167.82.224.0"/20;  # Fastly cache node
}

acl allowed_ip_addresses {
  %{ for ip_address in allowed_ip_addresses ~}
  "${ip_address}";
  %{ endfor ~}
}

sub vcl_recv {

  # Require authentication for FASTLYPURGE requests unless from IP in ACL
  if (req.request == "FASTLYPURGE" && client.ip !~ purge_ip_allowlist) {
    set req.http.Fastly-Purge-Requires-Auth = "1";
  }

  %{ if basic_authentication_encoded_secret != "" }
  if (! (client.ip ~ allowed_ip_addresses)) {
    # Check whether the basic auth credentials are correct in integration
    if (req.http.Authorization != "Basic ${basic_authentication_encoded_secret}") {
      error 401 "Unauthorized";
    }
  }
  %{ endif }

  # Force SSL.
  if (!req.http.Fastly-SSL) {
     error 801 "Force SSL";
  }

  # Serve a 404 Not Found response if request URL matches "/autodiscover/autodiscover.xml"
  if (req.url.path ~ "(?i)/autodiscover/autodiscover.xml$") {
    error 804 "Not Found";
  }

  # Serve from stale for 24 hours if origin is sick
  set req.grace = 24h;

  # Default backend, these details will be overwritten if other backends are
  # chosen
  set req.backend = origin;
  set req.http.Fastly-Backend-Name = "origin";

  # Set header to show recommended related links for Whitehall content. This is to be used
  # as a rollback mechanism should we ever need to stop showing these links.
  set req.http.Govuk-Use-Recommended-Related-Links = "true";

  # Set a request id header to allow requests to be traced through the stack
  set req.http.GOVUK-Request-Id = uuid.version4();

  if (req.url.path == "/find-coronavirus-local-restrictions") {
    # get rid of all but the postcode param
    set req.url = querystring.filter_except(req.url, "postcode");
  }

  # Unspoofable original client address (e.g. for rate limiting).
  set req.http.True-Client-IP = req.http.Fastly-Client-IP;

  # Reset proxy headers at the boundary to our network.
  unset req.http.Client-IP;
  set req.http.X-Forwarded-For = req.http.Fastly-Client-IP;

  # Set a TLSversion request header for requests going to the Licensify application
  # This is used to block unsecure requests at the application level for payment security reasons and an absence of caching in Licensify
  if (req.url ~ "^/apply-for-a-licence/.*") {
    set req.http.TLSversion = tls.client.protocol;
  }

%{ if basic_authentication_encoded_secret != "" }
  if (req.backend == origin) {
    set req.http.Authorization = "Basic ${basic_authentication_encoded_secret}";
  }
%{ endif }

#FASTLY recv

  if (req.request != "HEAD" && req.request != "GET" && req.request != "FASTLYPURGE") {
    return(pass);
  }

  if (req.http.Cookie ~ "_finder-frontend_account_session") {
    set req.http.GOVUK-ABTest-AccountExperiment = "LoggedIn";
  } else {
    set req.http.GOVUK-ABTest-AccountExperiment = "LoggedOut";
  }

  return(lookup);
}

sub vcl_fetch {
#FASTLY fetch

  set beresp.http.Fastly-Backend-Name = req.http.Fastly-Backend-Name;

  if ((beresp.status >= 500 && beresp.status <= 599) && req.restarts < 3 && (req.request == "GET" || req.request == "HEAD") && !beresp.http.No-Fallback) {
    set beresp.saintmode = 5s;
    return (restart);
  }

  if (req.restarts == 0) {
    # Keep stale for origin
    set beresp.grace = 24h;
  }

  if(req.restarts > 0 ) {
    set beresp.http.Fastly-Restarts = req.restarts;
  }


  if (beresp.status >= 500 && beresp.status <= 599) {
    set req.http.Fastly-Cachetype = "ERROR";
    set beresp.ttl = 1s;
    set beresp.grace = 5s;
    return (deliver);
  }

  if (beresp.http.Cache-Control ~ "private") {
    set req.http.Fastly-Cachetype = "PRIVATE";
    return (pass);
  }

  if (beresp.http.Cache-Control ~ "max-age=0") {
    return (pass);
  }

  if (beresp.http.Cache-Control ~ "no-(store|cache)") {
    return (pass);
  }

  # Fastly doesn't recognise 307 as cacheable by default as it is based on an
  # old version of Varnish that also lacked 307 support.
  if (beresp.status == 307) {
    set beresp.cacheable = true;
  }

  if (beresp.http.Expires || beresp.http.Surrogate-Control ~ "max-age" || beresp.http.Cache-Control ~"(s-maxage|max-age)") {
    # keep the ttl here
  } else {
    # apply the default ttl
    set beresp.ttl = ${default_ttl}s;
  }

  # Override default.vcl behaviour of return(pass).
  if (beresp.http.Set-Cookie) {
    return (deliver);
  }
}

sub vcl_hit {
#FASTLY hit
}

sub vcl_miss {
#FASTLY miss
}

sub vcl_deliver {
#FASTLY deliver
}

sub vcl_error {
  if (obj.status == 801) {
    set obj.status = 301;
    set obj.response = "Moved Permanently";
    set obj.http.Location = "https://" req.http.host req.url;
    set obj.http.Fastly-Backend-Name = "force_ssl";
    synthetic {""};
    return (deliver);
  }

  # Arbitrary 302 redirects called from vcl_recv.
  if (obj.status == 802) {
    set obj.status = 302;
    set obj.http.Location = "https://" req.http.host obj.response;
    set obj.response = "Moved";
    synthetic {""};
    return (deliver);
  }

  if (obj.status == 804) {
    set obj.status = 404;
    set obj.response = "Not Found";
    set obj.http.Fastly-Backend-Name = "force_not_found";

    synthetic {"
      <!DOCTYPE html>
      <html>
        <head>
          <title>Welcome to GOV.UK</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 0; }
            header { background: black; }
            h1 { color: white; font-size: 29px; margin: 0 auto; padding: 10px; max-width: 990px; }
            p { color: black; margin: 30px auto; max-width: 990px; }
          </style>
        </head>
        <body>
          <header><h1>GOV.UK</h1></header>
          <p>We cannot find the page you're looking for. Please try searching on <a href="https://www.gov.uk/">GOV.UK</a>.</p>
        </body>
      </html>"};

    return (deliver);
  }

  %{ if basic_authentication_encoded_secret != "" }
  if (obj.status == 401) {
    set obj.http.WWW-Authenticate = "Basic";
    synthetic {""};
    return (deliver);
  }
  %{ endif }

  # Serve stale from error subroutine as recommended in:
  # https://docs.fastly.com/guides/performance-tuning/serving-stale-content
  # The use of `req.restarts == 0` condition is to enforce the restriction
  # of serving stale only when the backend is the origin.
  if ((req.restarts == 0) && (obj.status >= 500 && obj.status < 600)) {
    /* deliver stale object if it is available */
    if (stale.exists) {
      return(deliver_stale);
    }
  }

  # Assume we've hit vcl_error() because the backend is unavailable
  # for the first two retries. By restarting, vcl_recv() will try
  # serving from stale before failing over to the mirrors.
  if (req.restarts < 3) {
    return (restart);
  }

  set obj.http.Fastly-Backend-Name = "error";
  synthetic {"
    <!DOCTYPE html>
    <html>
      <head>
        <title>Welcome to GOV.UK</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 0; }
          header { background: black; }
          h1 { color: white; font-size: 29px; margin: 0 auto; padding: 10px; max-width: 990px; }
          p { color: black; margin: 30px auto; max-width: 990px; }
        </style>
      </head>
      <body>
        <header><h1>GOV.UK</h1></header>
        <p>We're experiencing technical difficulties. Please try again later.</p>
        <p>You can <a href="/coronavirus">find coronavirus information</a> on GOV.UK.</p>
      </body>
    </html>"};

  return (deliver);

#FASTLY error
}

# pipe cannot be included.

sub vcl_pass {
#FASTLY pass
}

sub vcl_hash {
#FASTLY hash
}
