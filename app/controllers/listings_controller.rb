class ListingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /listings/rentals
  def index
    service = RentcastService.new
    response = service.rental_listings(permitted_params)
    render json: response.parsed_response, status: response.code
  end

  # GET /listings/rentals/:id
  def show
    service = RentcastService.new
    response = service.rental_listing(params[:id])
    render json: response.parsed_response, status: response.code
  end

  private

  def permitted_params
    params.permit(
      :city, :state, :zipCode, :latitude, :longitude, :radius,
      :propertyType, :bedrooms, :bathrooms, :squareFootage, :lotSize, :yearBuilt,
      :price, :daysOld, :status, :listingType, :limit, :offset
    )
  end
end
