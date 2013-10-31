# encoding: utf-8

module SessionsHelper
  def sign_in(user)
    if session[:remember_me]
      logger.info "Logging in user permanently"
      cookies.permanent[:remember_token] = user.remember_token
    else
      logger.info "Logging in user temporarily"
      cookies[:remember_token] = user.remember_token
    end
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    # avoid query for non-signed in users
    return nil if cookies[:remember_token].nil?
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def current_user_id
    signed_in? ? current_user.id : -1
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Bitte logge Dich ein um diese Funktion nutzen zu können."
    end
  end

  def sign_out
    current_user = nil
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end


  def admin?
    current_user && current_user.admin?
  end

  def reviewer?
    current_user && current_user.reviewer?
  end

  def require_admin
    redirect_to(root_url) unless admin?
  end

  def require_reviewer
    redirect_to(root_url) unless reviewer?
  end

  def require_admin_or_reviewer
    redirect_to(root_url) unless admin? or reviewer?
  end
end
