class AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:signup, :login]

  def signup
    user = User.new(user_params)
    if user.save
      token = encode_token({ user_id: user.id })
      render json: { user: user, token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_token({ user_id: user.id })
      render json: { user: user, token: token }
    else
      render json: { error: "Invalid email/password" }, status: :unauthorized
    end
  end

  private
  def user_params
    params.permit(:name, :email, :password, :avatar_url)
  end

  def encode_token(payload)
    secret = ENV.fetch("SECRET_KEY_BASE")
    JWT.encode(payload, secret)
  end
end
