require 'httparty'
require 'uri'
require 'digest/md5'

class RentcastSearchService
  include HTTParty
  base_uri 'https://api.rentcast.io/v1'

  def initialize
    @headers = { 'X-Api-Key' => ENV['RENTCAST_KEY'], 'Accept' => 'application/json' }
  end

  # Search rental listings with caching (but using friendlier params)
  def rental_listings(params = {})
    query = build_query(params)

    cache_key = "rentcast_search/#{Digest::MD5.hexdigest(query.to_query)}"

    Rails.cache.fetch(cache_key, expires_in: 30.days) do
      response = self.class.get('/listings/rental/long-term', headers: @headers, query: query)
      raise "RentCast API error: #{response.code}" unless response.success?

      response.parsed_response
    end
  end

  private

  # Translate friendly min/max params → RentCast syntax
  def build_query(params)
    params = params.to_h.symbolize_keys
    rc_params = {}

    RANGE_PARAM_MAP.each do |friendly_key, rc_key|
      min_key = :"min_#{friendly_key}"
      max_key = :"max_#{friendly_key}"

      if params[min_key] || params[max_key]
        min_val = params[min_key]
        max_val = params[max_key]

        rc_params[rc_key] =
          if min_val && max_val
            "#{min_val}:#{max_val}"
          elsif min_val
            "#{min_val}:*"
          else
            "*:#{max_val}"
          end
      end
    end

    # Handle array inputs (e.g. bedrooms: [2,3] → "2|3")
    RANGE_PARAM_MAP.each do |friendly_key, rc_key|
      if params[friendly_key].is_a?(Array)
        rc_params[rc_key] = params[friendly_key].join("|")
      end
    end

    # Merge raw allowed params (snake_case → camelCase if mapped)
    params.each do |k, v|
      next if k.to_s.start_with?("min_") || k.to_s.start_with?("max_")
      next if RANGE_PARAM_MAP.key?(k) && v.is_a?(Array)

      rc_key = RANGE_PARAM_MAP[k] || k
      rc_params[rc_key] = v if ALLOWED_PARAMS.include?(rc_key.to_s)
    end

    rc_params
  end

  ALLOWED_PARAMS = %w[
    city state zipCode latitude longitude radius
    propertyType bedrooms bathrooms squareFootage lotSize yearBuilt
    price daysOld status listingType limit offset
  ].freeze

  RANGE_PARAM_MAP = {
    bedrooms: :bedrooms,
    bathrooms: :bathrooms,
    square_footage: :squareFootage,
    lot_size: :lotSize,
    year_built: :yearBuilt,
    price: :price,
    days_old: :daysOld
  }.freeze
end
