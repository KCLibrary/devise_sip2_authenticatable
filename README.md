Devise Sip2 Authenticatable
===========================

This gem provides a Sip2 strategy for the the [Devise](http://github.com/plataformatec/devise) authentication framework.

Prerequisites
-------------
 * devise >= 3.0.0
 
Usage
-----

Install Devise and configure according to instructions.

In your `Gemfile`:

    gem "devise_sip2_authenticatable", :git => 'https://github.com/kardeiz/devise_sip2_authenticatable.git'

Somewhere in your `config` folder, define a file `sip2.yml` that contains your Sip2 connection information, e.g.:

    development: &connection
      host: <your Sip2 server host>
      port: <your Sip2 server port>
      ao: <your Sip2 institution ID>
  
    production:
      <<: *connection

In your user model, make sure you specify `:sip2_authenticatable` as a Devise strategy, e.g.:

    devise :sip2_authenticatable, :rememberable, :trackable

That's pretty much it. After validating a user, this gem will call a method `:after_sip2_validation` with a post-validation authentication hash as argument, if this method is defined on your user model. You can use this method to store information about your user. Currently the hash contains the following fields/values: 

    <auth_key>, password, last_name, first_name, email

If you use this method to make changes to the user instance, these changes will be saved.

