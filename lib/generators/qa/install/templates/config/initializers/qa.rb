Qa.config do |config|
  # When enabled, CORS headers will be added to the responses for search and show.  `OPTIONS` method will also be supported.
  # Uncomment one of the lines below to enable or disable CORS headers.  This configuration defaults to disabled when not set.
  # More information on CORS headers at: https://fetch.spec.whatwg.org/#cors-protocol
  # config.enable_cors_headers
  # config.disable_cors_headers

  # Provide a token that allows reloading of linked data authorities through the controller
  # action '/reload/linked_data/authorities?auth_token=YOUR_AUTH_TOKEN_DEFINED_HERE' without
  # requiring a restart of rails. By default, reloading through the browser is not allowed
  # when the token is nil or blank.  Change to any string to control who has access to reload.
  # config.authorized_reload_token = 'YOUR_AUTH_TOKEN_DEFINED_HERE'
end
