class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  before_action :check_owner, only: [:show,:update, :destroy,:edit]

  def index
    @applications = current_user.oauth_applications
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url( @application )
    else
      render :new
    end
  end

  protected

  def check_owner
    if @application.owner == current_user
    else
      flash[:error] ="Cette application ne vous appartient pas"
      redirect_to oauth_applications_path
    end
  end
end
