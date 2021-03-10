class Entry < ApplicationRecord
  belongs_to :category
  belongs_to :timeslot, optional: true
  belongs_to :fair
  belongs_to :location, optional: true

  has_many :user_entries, dependent: :destroy
  has_many :users, through: :user_entries
  has_many :judge_assigns, dependent: :destroy
  has_many :scoresheets, dependent: :destroy

  has_one :prior_entry, class_name: "Entry"

  validates_presence_of :entry_name

  scope :user_entries, -> (user) { joins(:user_entries).where('user_entries.user_id = ?', user.id) }
  scope :judge_assigned_entries, -> (user) { joins(:judge_assigns).where('judge_assigns.user_id = ?', user.id) }
  scope :fair_entries, -> (fair) { where('fair_id = ?', fair) }
  scope :in_schedule_order, -> { joins(:timeslot).order(order: :asc) }
  scope :non_pents, -> (fair) { where(pentathlon: false).where('fair_id = ?', fair.id) }
  scope :pentathlons, -> (fair) { where(pentathlon: true).where('fair_id = ?', fair.id) }
  scope :divisions, -> (fair) { where(division: true).where('fair_id = ?', fair.id) }
  scope :qualified_pents, -> (fair, disqualified_users) { pentathlons(fair).joins(:user_entries).where.not(:user_entries => {user_id: disqualified_users}) }
  scope :disqualified_pents, -> (fair, disqualified_users) { pentathlons(fair).joins(:user_entries).where(:user_entries => {user_id: disqualified_users}) }

  def timeslot_description
    self.timeslot.nil? ? "Unassigned" : self.timeslot.description
  end

  def location_description
    self.location.nil? ? "Unassigned" : self.location.description
  end

  def in_person_option
    self.in_person ? "Face-to-face" : "Not face-to-face"
  end

  def scored_option
    self.scored ? "Scored" : "Commentary Only"
  end

  def judge_name_or_unnassigned
    if self.judge_assigns.empty?
      'Unassigned'
    else
      judges = self.judge_assigns.map do |judge|
        judge.user.email_or_name
      end
      judges.join("<br>")
    end
  end

  def entrant_string
    users.map do |user|
      user.email_or_name
    end.join(" ")
  end

  def pent_or_div
    return "Div | " if self.division
    return "Pent | " if self.pentathlon
    ""
  end

  def final_score
    return 0 if scoresheets.empty?
    entry_scoresheets = scoresheets.select{ |x| !x.shadow_scoresheet? }

    return 0 if entry_scoresheets.empty?

    sum = 0
    entry_scoresheets.map do |scoresheet|
      sum = sum + scoresheet.total_score
    end

    (sum / entry_scoresheets.count).truncate(2)
  end
end
