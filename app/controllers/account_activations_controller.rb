class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activate, true)
      user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = "Welcome! Your account has been activated.  You can now save and vote on tracks or submit your own."
      redirect_to user
    else
      flash[:danger] = "Invalid activation link.  Please check the link or request a new code."
      redirect_to root_url
    end
  end

end
