class Entry < ApplicationRecord
  belongs_to :category
  belongs_to :timeslot, optional: true
  belongs_to :fair

  has_many :user_entries
  has_many :judge_assigns
  has_many :scoresheets

  scope :user_entries, -> (user) { joins(:user_entries).where('user_entries.user_id = ?', user.id) }
  scope :judge_assigned_entries, -> (user) { joins(:judge_assigns).where('judge_assigns.user_id = ?', user.id) }
  scope :fair_entries, -> (fair) { where('fair_id = ?', fair.id) }
  scope :in_schedule_order, -> { joins(:timeslot).order(order: :asc) }

  def timeslot_description
    self.timeslot.nil? ? "Unassigned" : self.timeslot.description
  end

  def in_person_option
    self.in_person ? "Face-to-face" : "Not face-to-face"
  end

  def scored_option
    self.scored ? "Scored" : "Commentary Only"
  end

  def judge_name_or_unnassigned
    self.judge_assigns.empty? ? 'Unassigned' : self.judge_assigns.last.user.email
  end
end
