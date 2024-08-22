class ApplicationController < ActionController::API
  def render_error_msg(error_msg, status = :unprocessable_entity)
    render json: { message: error_msg }, status: status
  end
end
