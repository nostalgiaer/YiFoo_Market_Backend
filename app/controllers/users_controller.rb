class UsersController < ApplicationController
  before_action :login_only, except: [:register, :login, :index, :create_admin]
  # before_action :unlogin_only, only: [:register, :login]
  before_action :_find_user, only: [:modify_username, :modify_password, :modify_email]

  public

  def login
    _email = params[:userId]
    _email = _email.to_s.downcase if _email

    _student_id = params[:userId]
    _student_id = _student_id.to_s.downcase if _student_id

    unless _email || _student_id
      render json: response_json(
        false,
        message: LoginError::NO_VALID_INFORMATION_PROVIDED,
      ) and return
    end

    _password = params[:password]
    user = User.find_by(email: _email) || User.find_by(student_id: _student_id)

    unless user
      render json: response_json(
        false,
        message: LoginError::USER_NOT_EXISTED
      ) and return
    end

    _last_failure_time = user.last_failure_on_login
    _failure_times = user.failures_on_login
    if _failure_times >= 5 and Time.now - _last_failure_time < 1.hour
      render json: response_json(
        false,
        message: LoginError::LOGIN_FAILED_TOO_MANY_TIMES
      ) and return
    end

    unless user.authenticated? _password
      user.last_failure_on_login = Time.now
      user.failures_on_login = _failure_times + 1
      user.save
      render json: response_json(
        false,
        message: LoginError::WRONG_PASSWORD_PROVIDED
      ) and return
    end

    _remember = params[:remember]

    puts _remember
    log_in user, _remember
    user.failures_on_login = 0
    user.save
    _image_relative_path = "/users/#{current_user.id}.png"
    _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + _image_relative_path
    _image_url = "http://localhost:#{PORT}/users/#{current_user.id}.png" if File.exist? _image_path
    render status: 200, json: response_json(
      true,
      message: LoginError::LOGIN_SUCCESS,
      data: {
        username: user.username,
        userId: user.student_id,
        email: user.email,
        password: user.password,
        role: user.user_role,
        avatar: _image_url
      }
    )
  end

  def register
    if User.find_by(student_id: params[:userId])
      render json: response_json(
        false,
        message: RegisterError::EXISTED_USER
      ) and return
    end

    if User.find_by(email: params[:email])
      render json: response_json(
        false,
        message: RegisterError::EXISTED_USER
      ) and return
    end

    user = User.new username: params[:username], student_id: params[:userId],
                    email: params[:email]
    user.password = params[:password]
    user.failures_on_login = 0
    user.uploaded = 0
    if user.save
      render status: 200, json: response_json(
        true,
        message: Global::SUCCESS
      )
    else
      render json: response_json(
        false,
        message: RegisterError::INVALID_INFORMATION
      )
    end
  end

  def modify_password
    _user = @user
    if _user.authenticated? params[:oldPassword]
      _user.password = params[:newPassword]
      _user.uploaded = 1
      if _user.save
        render status: 200, json: response_json(
          true,
          message: UserOperationError::OPERATION_SUCCESS
        )
      else
        render json: response_json(
          false,
          message: UserOperationError::OPERATION_FAIL
        )
      end
    else
      render json: response_json(
        false,
        message: UserOperationError::PASSWORD_NOT_MATCH
      )
    end
  end

  def modify_email
    _user = @user
    if _user.authenticate_email? params[:oldEmail]
      _user.email = params[:newEmail]
      if _user.save
        render status: 200, json: response_json(
          true,
          message: UserOperationError::OPERATION_SUCCESS
        )
      else
        render json: response_json(
          false,
          message: UserOperationError::OPERATION_FAIL
        )
      end
    else
      render json: response_json(
        false,
        message: UserOperationError::EMAIL_NOT_MATCH
      )
    end
  end

  def modify_username
    _user = @user
    _user.username = params[:username]
    if _user.save
      render status: 200, json: response_json(
        true,
        message: UserOperationError::OPERATION_SUCCESS
      )
    else
      render json: response_json(
        false,
        message: UserOperationError::OPERATION_FAIL
      )
    end
  end

  def avatar
    _image_relative_path = "/users/#{current_user.id}.png"
    _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + _image_relative_path

    _image = File.open(params[:avatar].path, 'rb')
    File.new(_image_path, "w+")
    _local_image = File.open(_image_path, 'wb') << _image.read
    _image.close

    render status: 200, json: response_json(
      true,
      message: nil,
      data: {
        newAvatar: "http://localhost:#{PORT}/users/#{current_user.id}.png"
      }
    )
  end

  def show
    _user = User.find_by(id: params[:id].to_i)
    _image_relative_path = "/users/#{_user.id}.png"
    _image_path = File.expand_path(File.dirname(__FILE__) + "/../..") + "/public" + _image_relative_path
    _image_url = "http://localhost:#{PORT}/users/#{_user.id}.png" if File.exist? _image_path
    render status: 200, json: response_json(
      true,
      data: {
        studentId: _user.student_id,
        username: _user.username,
        email: _user.email,
        role: _user.user_role,
        avatar: _image_url
      }
    )
  end

  def follows
    render status: 200, json: response_json(
      true,
      message: nil,
      data: {
        followPosts: current_user.follow_infos.collect do |_follow|
          _post = Post.find_by(id: _follow.post_id)
          if _post.is_buy_post?
            image_url = "http://localhost:#{PORT}/buy_posts/#{_post.id}.png"
          else
            _first_commodity = _post.commodities.first
            image_url = "http://localhost:#{PORT}/commodities/#{_first_commodity.id}.png" unless _first_commodity.nil?
          end
          {
            postId: _post.id,
            category: _post.category,
            title: _post.title,
            authorName: _post.author.username,
            annotation: _follow.annotation,
            favorite: 1,
            heat: _post.heat,
            userId: current_user.id,
            postImg: image_url,
            tags: _post.tags.collect do |_tag|
              {
                tagName: _tag.tag_name
              }
            end
          }
        end
      }
    )
  end

  def create_admin
    _username = 'admin'
    _student_id = '20003700'
    _email = '20003700@buaa.edu.cn'
    _passwd = '20003700'
    user = User.new username: _username, student_id: _student_id,
                    email: _email, password: _passwd
    user.failures_on_login = 0
    user.user_role = 2
    if user.save
      render status: 200, json: response_json(
        true,
        message: "create admin success"
      )
    else
      render json: response_json(
        false,
        message: "create admin fail!"
      )
    end
  end

  def index
  end

  private

  def _find_user
    @user = current_user
    unless @user
      render json: response_json(
        false,
        message: UserOperationError::USER_NOT_FOUND
      )
      false
    end
  end

end
