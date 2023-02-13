class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  PORT = 5000

  include ApplicationHelper

  include SessionsHelper

  def login_only
    puts session[:user_id]
    if logged_in?
      true
    else
      render status: 401, json: response_json(
        false,
        message: "Please login firstly!"
      )
    end
  end

  def unlogin_only
    if not logged_in?
      true
    else
      render status: 403, json: response_json(
        false,
        message: "You have logged in!"
      )
    end
  end

end
