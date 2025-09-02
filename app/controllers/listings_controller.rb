class ListingsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  # GET /listings/rentals
  def index
    service = RentcastService.new
    listings = service.rental_listings(permitted_params)

    # render json: listings, status: :ok
    render json: {
    count: listings.size,
    listings: listings
  }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
  end

 def homepage
    service = RentcastService.new
    listings = service.rental_listings(limit: 10)
    render json: listings, status: :ok
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
  end

  # GET /listings/rentals/:id
  def show
    service = RentcastService.new
    response = service.rental_listing(params[:id])

    render json: response.parsed_response, status: response.code
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
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
