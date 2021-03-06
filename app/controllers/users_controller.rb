class UsersController < ApplicationController

  # == Enabled Before Filters ==

  before_action :logged_in_user,
                only: [:index, :edit, :update, :destroy]
  before_action :correct_user,
                only: [:edit, :update]
  before_action :admin_user,
                only: :destroy

  # == Routes ==

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # FollowUpEmailJob.new(@user.email).enqueue(wait: 10.seconds) # Generic ActiveJob style
      UserMailer.follow_up_email(@user.email).deliver_later!(wait: 10.seconds) # ActiveMailer style
      log_in @user
      flash[:success] = 'Welcome to Ohmbrewer!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  private

    # Strong parameter requirements to be enforced when creating a User
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

end
