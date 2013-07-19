# encoding: utf-8

require 'devise'
require 'devise_sip2_authenticatable/adapter'

Devise.add_module(:sip2_authenticatable, {
  :route => :session,
  :strategy   => true,
  :controller => :sessions,
  :model  => "devise_sip2_authenticatable/model"
})
