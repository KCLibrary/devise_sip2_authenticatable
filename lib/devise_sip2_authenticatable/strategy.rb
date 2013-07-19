require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class Sip2Authenticatable < Authenticatable
      def authenticate!
        auth = authentication_hash.merge(:password => password)
        resource = valid_password? && mapping.to.authenticate_with_sip2(auth)
        return fail(:invalid) unless resource
        success! if validate(resource)
      end
    end
  end
end

Warden::Strategies.add(:sip2_authenticatable, Devise::Strategies::Sip2Authenticatable)
