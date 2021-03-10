class JudgeAssign < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  scope :for_fair, -> (fair) { joins(:entry).where('entries.fair_id = ?', fair) }
end
