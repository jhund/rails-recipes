class UsersController < ApplicationController

  def index
    raise SecurityTransgression unless User.listable_by?(current_user)
    @users = User.find(:all)

    respond_to do |format|
      format.html
    end
  end

  def show
    @user = User.find(params[:id])
    raise SecurityTransgression unless @user.viewable_by?(current_user)

    respond_to do |format|
      format.html
    end
  end

  def new
    @user = User.new
    raise SecurityTransgression unless @user.creatable_by?(current_user)
  end

  def edit
    @user = User.find(params[:id])
    raise SecurityTransgression unless @user.updatable_by?(current_user)
  end

  def create
    @user = User.new(params[:user])
    raise SecurityTransgression unless @user.creatable_by?(current_user)

    @user.save!
    self.current_user = @user
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def update
    @user = User.find(params[:id])
    raise SecurityTransgression unless @user.updatable_by?(current_user)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    raise SecurityTransgression unless @user.destroyable_by?(current_user)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.js   # render rjs
    end
  end

end
