# Adding a Backend App

To add a backend app, e.g. a publishing app, to the platform:

1. following the general instructions in [adding-an-app documentation](adding-an-app.md)

2. add the app to the list of `fronted_apps` of the backends origin
   [here](../govuk-publishing-platform/backends_origin.tf)

3. it is also necessary to add there the `target group` and `listener rules`
   which will direct the traffic on the the backends origin to the newly added
   app
