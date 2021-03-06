class Fair < ApplicationRecord
  belongs_to :region

  has_many :entries
  has_many :judge_fairs
  has_many :locations

  scope :allowed, -> { where(entries_allowed: true) }
  scope :current, -> { where(finalized: false) }
  scope :kingdom, -> { where(kingdom: true) }
  scope :in_order, -> { order(:date) }

  def name_with_warning
    self.internet_access ? self.name : "#{self.name} - WARNING: electronic judging not available"
  end
end
