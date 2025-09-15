class FavoritesController < ApplicationController
  before_action :authenticate_user!  # Devise or JWT auth

  def index
    favorites = current_user.favorites
    render json: favorites
  end

  def create
    favorite = current_user.favorites.new(listing_id: params[:listing_id])
    if favorite.save
      render json: favorite, status: :created
    else
      render json: { error: favorite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    favorite = current_user.favorites.find_by(listing_id: params[:listing_id])
    if favorite&.destroy
      head :no_content
    else
      render json: { error: "Favorite not found" }, status: :not_found
    end
  end
end
