require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          ldap = Net::LDAP.new
          ldap.host = LDAP_CONFIG["host"]
          ldap.port = LDAP_CONFIG["port"]
          ldap.auth LDAP_CONFIG["auth_dn"], LDAP_CONFIG["auth_pass"]

          filter = Net::LDAP::Filter.eq( "uid", params[:user][:email])
          treebase = LDAP_CONFIG["search_base"]

          results = ldap.search( :base => treebase, :filter => filter, :scope => Net::LDAP::SearchScope_WholeSubtree)
          if results.length == 1
            ldap.auth results[0][:dn], password
            if ldap.bind
              user = User.find_or_create_by(uid: results[0][:uid][0])
              user.update({uid: results[0][:uid][0], password: "dummydummy", promo: results[0][:roomnumber][0], lastname: results[0][:sn][0], name: results[0][:givenname][0], phone: results[0][:mobile][0], address: results[0][:postalAddress][0], email: results[0][:mail][0]})
              user.save!
              success!(user)
            else
              fail(:invalid_login)
            end
          else
            fail(:invalid_login)
          end
        end
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
