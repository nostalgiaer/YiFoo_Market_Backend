module ApplicationHelper

  module Global
    SUCCESS = "success"
    PORT = 5000
  end



  module LoginError
    extend Global

    NO_VALID_INFORMATION_PROVIDED = "No Email or StudentId is provided"
    WRONG_PASSWORD_PROVIDED = "Password is wrong"
    LOGIN_FAILED_TOO_MANY_TIMES = "You had failed too times, Please wait for 1 hour!"
    LOGIN_SUCCESS = "Login Success"
    USER_NOT_EXISTED = "User is not existed"
  end

  module RegisterError
    extend Global

    EXISTED_USER = "The User has existed!"
    INVALID_INFORMATION = "Register Fail!"
  end

  module UserOperationError
    extend Global

    OPERATION_SUCCESS = "Operate Success!"
    OPERATION_FAIL = "Operate Fail!"
    PASSWORD_NOT_MATCH = "Password not match"
    EMAIL_NOT_MATCH = "Email not match"
    USER_NOT_FOUND = "Not find user"
  end

  module PostOperationError
    extend Global

    POST_NOT_EXISTED = "Post not existed"
    POST_ACCESS_DENIED = "Your operation is denied"
    POST_OPERATION_SUCCESS = "success"
    POST_CREATE_FAIL = "Create Post Fail!"
    POST_DELETE_FAIL = "Delete Post Fail!"
    POST_UPDATE_FAIL = "Update Post Fail!"
  end

  def response_json(success, message: nil, data: nil)
    {
      success: success,
      message: message || (success ? "Success." : "Failed"),
      data: data
    }
  end

end
