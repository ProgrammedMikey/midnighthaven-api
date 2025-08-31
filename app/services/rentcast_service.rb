require 'httparty'
require 'uri'

class RentcastService
  include HTTParty
  base_uri 'https://api.rentcast.io/v1'

  def initialize
    @headers = { 'X-Api-Key' => ENV['RENTCAST_KEY'], 'Accept' => 'application/json' }
  end

  # Search rental listings
  def rental_listings(params = {})
    query = filter_params(params)
    self.class.get('/listings/rental/long-term', headers: @headers, query: query)
  end

  # Get a single rental listing by ID
  def rental_listing(id)
    self.class.get("/listings/rental/long-term/#{URI.encode_www_form_component(id)}", headers: @headers)
  end

  private

  # Only allow params supported by RentCast
  ALLOWED_PARAMS = %w[
    city state zipCode latitude longitude radius
    propertyType bedrooms bathrooms squareFootage lotSize yearBuilt
    price daysOld status listingType limit offset
  ].freeze

  def filter_params(params)
    params.to_h.slice(*ALLOWED_PARAMS)
  end
end
