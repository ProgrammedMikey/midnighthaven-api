class ListingsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def homepage_city_listings
    service = RentcastService.new

    # Frontend passes ?cities=Miami,Orlando
    cities = params[:cities]&.split(',') || %w[Miami]
    state = params[:state] || 'FL'
    limit = (params[:limit] || 10).to_i

    results = cities.map do |city|
      listings = service.rental_listings(
        'city' => city,
        'state' => state,
        'limit' => limit,
        'daysOld' => '*:30',
        'status' => 'active'
      )

      sorted_listings = listings.sort_by { |l| l['listedDate'] }.reverse
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

    if response.success?
      render json: format_single_listing(response.parsed_response), status: :ok
    else
      render json: { error: "Listing not found" }, status: :not_found
    end
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

  def format_single_listing(listing)
    {
      id:               listing['id'],
      formatted_address: listing['formattedAddress'],
      address_line1:    listing['addressLine1'],
      city:             listing['city'],
      state:            listing['state'],
      zip_code:         listing['zipCode'],
      property_type:    listing['propertyType'],
      bedrooms:         listing['bedrooms'],
      bathrooms:        listing['bathrooms'],
      sqft:             listing['squareFootage'],
      price:            listing['price'],
      days_on_market:   listing['daysOnMarket'],
      listing_agent:    listing['listingAgent'],
      listing_office:   listing['listingOffice'],
      thumbnail_url:    placeholder_image(listing['propertyType'])
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
