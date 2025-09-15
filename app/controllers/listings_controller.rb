class ListingsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def homepage_city_listings
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

      # map to only essential fields
      simplified_listings = sorted_listings.map { |l| format_listing(l) }

      { city: city, listings: simplified_listings }
    end

    render json: results, status: :ok
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def homepage_featured
    service = RentcastService.new

    listings = service.rental_listings(
      'price' => '3000:*', 
      'limit' => 10,
      'daysOld' => '*:7',
      'status' => 'active'
    )

    top_listings = listings.sort_by { |l| l['listedDate'] }.reverse

    featured_listings = top_listings.map { |l| format_listing(l) }

    render json: { type: "featured", listings: featured_listings }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
  end

  # GET /listings/rentals/:id
  def single_listing
    service = RentcastService.new
    response = service.rental_listing(params[:id])

    render json: response.parsed_response, status: response.code
  rescue => e
    render json: { error: e.message }, status: :bad_gateway
  end

  private

  def format_listing(listing)
    {
      id: listing['id'],
      address: listing['formattedAddress'],
      city: listing['city'],
      state: listing['state'],
      zip_code: listing['zipCode'],
      price: listing['price'],
      bedrooms: listing['bedrooms'],
      bathrooms: listing['bathrooms'],
      sqft: listing['squareFootage'],
      days_on_market: listing['daysOnMarket'],
      property_type: listing['propertyType'],
      thumbnail_url: placeholder_image(listing['propertyType'])
    }
  end


  def placeholder_image(property_type)
    case property_type
    when "Apartment" then "/images/placeholders/apartment.jpg"
    when "Condo" then "/images/placeholders/condo.jpg"
    when "Single Family" then "/images/placeholders/single_family.jpg"
    else "/images/placeholders/default.jpg"
    end
  end

  def permitted_params
    params.permit(
      :city, :state, :zipCode, :latitude, :longitude, :radius,
      :propertyType, :bedrooms, :bathrooms, :squareFootage, :lotSize, :yearBuilt,
      :price, :daysOld, :status, :listingType, :limit, :offset
    )
  end
end
