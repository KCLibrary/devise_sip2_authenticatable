require 'devise_sip2_authenticatable/strategy'

module Devise
  module Models
    module Sip2Authenticatable
      extend ActiveSupport::Concern
      included do
        attr_reader :current_password, :password
        attr_accessor :password_confirmation
      end
      
      def password=(new_password)
        @password = new_password
        if defined?(password_digest) && @password.present? && respond_to?(:encrypted_password=)
          self.encrypted_password = password_digest(@password) 
        end
      end      
      
      def sip2_auth_hash(_auth)
        s = Devise::Sip2.new
        s.get_patron_information(_auth)
      end
      
      module ClassMethods
        def authenticate_with_sip2(attributes={})
          auth_key = self.authentication_keys.first
          return nil unless attributes[auth_key].present?
          auth_key_value = attributes[auth_key]
          
          if self.case_insensitive_keys.try :include?, auth_key
            auth_key_value.downcase!
          end
          
          if self.strip_whitespace_keys.try :include?, auth_key
            auth_key_value.strip!
          end
          
          resource = where(auth_key => auth_key_value).first_or_initialize
          _auth = { :patron => auth_key_value, :patron_pwd => attributes[:password] }         
          sip2_obj = resource.sip2_auth_hash(_auth)
          
          if sip2_obj.delete(:valid)
            if resource.respond_to?(:sip2_before_save)
              resource.sip2_before_save( sip2_obj.merge(_auth) )
            end
            resource.save! if resource.new_record? or resource.changed?
            return resource
          else
            return nil
          end
        end
      end
    end
  end
end
