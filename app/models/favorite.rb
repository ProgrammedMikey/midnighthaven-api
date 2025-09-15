class Favorite < ApplicationRecord
  belongs_to :user

  validates :listing_id, presence: true
  validates :listing_id, uniqueness: { scope: :user_id }
end
