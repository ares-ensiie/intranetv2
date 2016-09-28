require "net/ldap"
class UsersController < ApplicationController
  before_action :set_user, except: ["index", :forgotten_password, :send_reset_instructions, :reset_password, :modify_password]

  def index
    @users = User.all.group_by {|user| user.promo}
    @users = @users.sort_by {|promo, list| -promo}
  end

  def edit
   if current_user.id != @user.id
      # flash[:error] = "Ne touchez pas aux informations des autres !"
      # redirect_to root_path
   end
  end

  def edit_password
    if current_user.id != @user.id
      flash[:error] = "Ne touchez pas aux informations des autres !"
      redirect_to root_path
    end
  end

  def update
    #if current_user.id == @user.id
      @user.update_attributes(params.require(:user).permit(:id, :avatar, :cv, :name, :lastname, :phone, :birthday, :address, :email, :github, :site, :facebook, :linkedin, :twitter))
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
      end
      redirect_to edit_user_path @user
    #else
    #  flash[:error] = "Ne touchez pas aux informations des autres !"
    #  redirect_to root_path
    #end
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
        flash[:error] = "Les mots de passe ne correspondent pas."
      end
    else
      flash[:error] = "Mot de passe doit contenir au moins 8 catactères"
    end
    redirect_to edit_user_path @user
  end

  def forgotten_password
  end

  def send_reset_instructions
    if params[:user] != ""
      user = params[:user]
      u = User.where('email = ? OR uid = ?', user, user).first
      if !u.nil?
        u.send_reset_password_instructions
        flash[:notice] = "Un mail contenant les instructions vous a été envoyé !"
      else
        flash[:error] = "Utilisateur inconnu"
      end
    else
      flash[:error] = "Veuillez entrer un nom d'utilisateur ou une adresse mail"
    end
    redirect_to forgotten_password_path
  end

  def reset_password
    if !params[:reset_password_token].nil?
      u = User.where('reset_password_token = ?', params[:reset_password_token]).first
      if !u.nil?
        if !u.reset_password_period_valid?
          flash[:error] = "Ce token n'est plus valide"
          redirect_to forgotten_password_path
        end
      else
        flash[:error] = "Ce token est inconnu"
        redirect_to forgotten_password_path
      end
    else
      redirect_to root_path
    end
  end

  def modify_password
    if !params[:token].nil?
      if params[:password].length > 7
        if params[:password] == params[:confirmation]
          u = User.where('reset_password_token = ?', params[:token]).first
          if !u.nil?
            ldap = init_ldap
            filter = Net::LDAP::Filter.eq( "uid", u.uid)
            treebase = LDAP_CONFIG["search_base"]

            results = ldap.search( :base => treebase, :filter => filter, :scope => Net::LDAP::SearchScope_WholeSubtree)
            if results.length == 1
              operations = [
                [:replace, :userPassword, "{md5}"+Base64.encode64(Digest::MD5.digest(params[:password])).chomp!]
              ]
              if ldap.modify :dn => results[0][:dn], :operations => operations
                u.reset_password_token = nil
                u.reset_password_sent_at = nil
                u.save
                flash[:notice] = "Mot de passe changé"
              else
                flash[:error] = "Impossible de changer le mot de passe. Ceci est un bug, merci de le signaler."
              end
            else
              flash[:error] = "Utilisateur introuvable. Ceci est un bug, merci de le signaler."
            end
          else
            flash[:error] = "Ce token n'existe pas."
          end
        else
          flash[:error] = "Les mots de passe ne correspondent pas."
          redirect_to '/users/reset_password?reset_password_token=' + params[:token]
          return
        end
      else
        flash[:error] = "Mot de passe doit contenir au moins 8 catactères"
        redirect_to '/users/reset_password?reset_password_token=' + params[:token]
        return
      end
      redirect_to forgotten_password_path
    else
      redirect_to root_path
    end
  end

  def profile
    @not_filled = 0
    if ! @user.lastname || @user.lastname == ""
      @not_filled += 1
    end
    if ! @user.name || @user.name == ""
      @not_filled += 1
    end
    if ! @user.birthday
      @not_filled += 1
    end
    if ! @user.email
      @not_filled += 1
    end
    if ! @user.phone
      @not_filled += 1
    end
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
