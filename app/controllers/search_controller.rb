class SearchController < ApplicationController
  def listings
    results = RentcastSearchService.new.rental_listings(search_params)

    # transform results before rendering
    transformed = results.map { |listing| transform_listing(listing) }

    render json: transformed
  rescue => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def transform_listing(raw)
    {
      id: raw['id'],
      formattedAddress: raw['formattedAddress'],
      city: raw['city'],
      state: raw['state'],
      zipCode: raw['zipCode'],
      propertyType: raw['propertyType'],
      bedrooms: raw['bedrooms'],
      bathrooms: raw['bathrooms'],
      squareFootage: raw['squareFootage'],
      price: raw['price'],
      status: raw['status'],
      listedDate: raw['listedDate'],
      daysOnMarket: raw['daysOnMarket'],
      latitude: raw['latitude'],
      longitude: raw['longitude']
    }
  end

  def search_params
    params.permit(
      :city, :state, :zipCode, :latitude, :longitude, :radius,
      :propertyType, :bedrooms, :bathrooms, :squareFootage, :lotSize, :yearBuilt,
      :price, :daysOld, :status, :listingType, :limit, :offset,
      :min_bedrooms, :max_bedrooms,
      :min_bathrooms, :max_bathrooms,
      :min_price, :max_price,
      :min_year_built, :max_year_built,
      :min_square_footage, :max_square_footage,
      :min_lot_size, :max_lot_size,
      :min_days_old, :max_days_old
    )
  end
end
