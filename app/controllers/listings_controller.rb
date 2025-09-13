class ListingsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def homepage
    service = RentcastService.new
    cities = %w[Miami]
    state = 'FL'
    limit = 10

    results = cities.map do |city|
      listings = service.rental_listings(
        'city' => city,
        'state' => state,
        'limit' => limit,
        'daysOld' => '*:30',
        'status' => 'active'
      )

      # sort newest first
      sorted_listings = listings.sort_by { |l| l['listedDate'] }.reverse

      { city: city, listings: sorted_listings }
    end

    render json: results, status: :ok
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
