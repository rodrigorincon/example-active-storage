class UsersController < ApplicationController
  # for testing this endpoint: curl --include --request POST http://localhost:3000/users --form "user[email]=email@email.com" --form "user[photo]=@imagem.png"
  # POST /users
  def create
    user = User.new(user_params)

    if user.save
      render json: UserSerializer.new(user).to_h, status: :created
    else
      render_error_msg(user.errors.full_messages.join(", "))
    end
  end

  # get /users/check_email
  def check_email
    user = User.find_by(email: params[:email])
    if user
      render json: UserSerializer.new(user).to_h
    else
      render json: nil
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :photo)
  end
end
