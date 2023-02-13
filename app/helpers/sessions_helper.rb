module SessionsHelper

  def log_in(user, _remember = true)
    session[:user_id] = user.student_id
    remember user if _remember
  end

  def current_user
    if (_user_id = session[:user_id])
      @current_user = User.find_by(student_id: _user_id)
    elsif (_user_id = cookies.signed[:user_id])
      _user = User.find_by(student_id: _user_id)
      if _user
        log_in _user, false
        @current_user = _user
      else
        @current_user = nil
      end
    else
      @current_user = nil
    end
  end

  def logged_in?
    current_user.present?
  end

  def remember(user = current_user)
    if user
      puts "preserve"
      _preserve_days = 1.days
      cookies.signed[:user_id] = {
        value: user.student_id,
        expires: _preserve_days.from_now.utc
      }
    end
  end

end
