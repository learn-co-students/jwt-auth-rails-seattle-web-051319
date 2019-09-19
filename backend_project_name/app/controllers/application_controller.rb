class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, 'my_s3cr3t')
  end

  def auth_header
    # reads header data from fetch request
    request.headers('Authorization')
  end
  
  def decoded_token
    # if there is authorization data in the header
    if auth_header
      # assign <token> of `Bearer <token>`
      token = auth_header.split(' ')[1]
      # then decode the token using the JWT (as a string), application secret, and a hashing algo
      # and retrieve the payload
      begin
        JWT.decode(token, 'mys3cr3t', true, algorithm: 'HS256')
      # rescue out of an exception
      # if token is invalid, raise an exception (500 internal server error)
      rescue JWT::DecodeError
        # return nil and move on
        nil
      end
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: {message: 'Please log in'}, status: :unauthorizerd unless logged_in?
  end
end
