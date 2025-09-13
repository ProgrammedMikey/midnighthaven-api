require 'httparty'
require 'uri'

class RentcastService
  include HTTParty
  base_uri 'https://api.rentcast.io/v1'

  def initialize
    @headers = { 'X-Api-Key' => ENV['RENTCAST_KEY'], 'Accept' => 'application/json' }
  end

  # Search rental listings with caching
  def rental_listings(params = {})
    query = filter_params(params)

    # Cache key based on query params
    cache_key = "rentcast_rentals/#{Digest::MD5.hexdigest(query.to_query)}"

    config.cache_store = :file_store, "#{root}/tmp/cache/"

    Rails.cache.fetch(cache_key, expires_in: 30.days) do
      response = self.class.get('/listings/rental/long-term', headers: @headers, query: query)
      raise "RentCast API error: #{response.code}" unless response.success?

      response.parsed_response
    end
  end

  # Get a single rental listing by ID (no caching needed for single items)
  def rental_listing(id)
    self.class.get("/listings/rental/long-term/#{URI.encode_www_form_component(id)}", headers: @headers)
  end

  private

  def filter_params(params)
   params.to_h.stringify_keys.slice(*ALLOWED_PARAMS)
  end

  ALLOWED_PARAMS = %w[
    city state zipCode latitude longitude radius
    propertyType bedrooms bathrooms squareFootage lotSize yearBuilt
    price daysOld status listingType limit offset
  ].freeze
end
