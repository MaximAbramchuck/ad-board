class AccountsController < ApplicationController
  
  def role
    @role = current_user.role
  end
  
  def change_role
    current_user.update(role_params)
    current_user.save
    redirect_to :back
  end

  def index
    if current_user.role == "admin"
      render "admin_account"
    elsif current_user.role == "user"
      render "user_account"
    end
  end
  
  def adverts
    @adverts = current_user.adverts.order(updated_at: :desc)
  end

  protected

  def role_params
    params.require(:user).permit(:role)
  end

end