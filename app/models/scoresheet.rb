class Scoresheet < ApplicationRecord
  belongs_to :user
  belongs_to :entry
  has_many :scores
  accepts_nested_attributes_for :scores

  scope :for_user, -> (user) { where("user_id = ?", user.id)}
end
