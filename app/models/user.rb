class User < ApplicationRecord
    has_secure_password
    has_many :listings
    has_many :bookings, foreign_key: :guest_id
    has_many :reviews
    has_many :favorites

    validates :email, presence: true, uniqueness: true
end
