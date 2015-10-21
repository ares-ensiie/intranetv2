require "net/ldap"
class UsersController < ApplicationController
  before_action :set_user, except: ["index"]

  def index
    @users = User.all.group_by {|user| user.promo}
    @users = @users.sort_by {|promo, list| -promo}
  end

  def edit
  end

  def edit_password
  end

  def update
    @user.update_attributes(params.require(:user).permit(:id, :current_password, :password, :confirmation, :name, :lastname, :phone, :birthday, :address, :email))
    ldap = init_ldap
    filter = Net::LDAP::Filter.eq("uid", @user.uid)
    treebase = LDAP_CONFIG["search_base"]
    results = ldap.search(:base => treebase, :filter => filter, :scope => Net::LDAP::SearchScope_WholeSubtree)
    if results.length == 1
      operations = [
        [:replace, :sn, @user.lastname],
        [:replace, :givenname, @user.name],
        [:replace, :mobile, @user.phone],
        [:replace, :postalAddress, @user.address],
        [:replace, :mail, @user.email]
      ]
      if ldap.modify :dn => results[0][:dn], :operations => operations
        flash[:notice] = "Informations mises a jour"
      else
        flash[:error] = "Erreur lors de la synchronisation avec LDAP"
      end
    else
      flash[:error] = "Erreur lors de la synchronisation avec LDAP"
    end

    redirect_to edit_user_path @user
  end

  def update_password
    if params[:password].length > 7
      if params[:password] == params[:confirmation]
        ldap = init_ldap
        filter = Net::LDAP::Filter.eq( "uid", @user.uid)
        treebase = LDAP_CONFIG["search_base"]

        results = ldap.search( :base => treebase, :filter => filter, :scope => Net::LDAP::SearchScope_WholeSubtree)
        if results.length == 1
          ldap.auth results[0][:dn], params[:current_password]
          if ldap.bind
            operations = [
              [:replace, :userPassword, "{md5}"+Base64.encode64(Digest::MD5.digest(params[:password])).chomp!]
            ]
            if ldap.modify :dn => results[0][:dn], :operations => operations
              flash[:notice] = "Mot de passe changé"
              sign_out @user
              redirect_to new_user_session_path
              return
            else
              flash[:error] = "Impossible de changer le mot de passe. Ceci est un bug, merci de le signaler."
            end
          else
            flash[:error] = "Mot de passe incorrect."
          end
        else
          flash[:error] = "Utilisateur introuvable. Ceci est un bug, merci de le signaler."
        end
      else
        flash[:error] = "Les mots de passes ne correspondent pas."
      end
    else
      flash[:error] = "Mot de passe doit contenir au moins 8 catactères"
    end
    redirect_to edit_user_path @user
  end

  protected

  def set_user
    @user = User.find(params[:id] || params[:user_id])
  end

  def init_ldap
    ldap = Net::LDAP.new
    ldap.host = LDAP_CONFIG["host"]
    ldap.port = LDAP_CONFIG["port"]
    ldap.auth LDAP_CONFIG["auth_dn"], LDAP_CONFIG["auth_pass"]
    return ldap
  end
end
