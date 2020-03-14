include FairsHelper

class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :assign_next_fair

  def index
    @entries = Entry.fair_entries(@next_fair).user_entries(current_user)
    @volunteered = !JudgeFair.find_by(user_id: current_user.id, fair_id: @next_fair.id).nil?
    puts @volunteered.inspect
  end

  def review
    @user = current_user
    @entries = Entry.fair_entries(@next_fair).user_entries(current_user).joins(:timeslot).order("timeslots.order")
    @judging = Entry.fair_entries(@next_fair).judge_assigned_entries(current_user).joins(:timeslot).order("timeslots.order")
    @everything = (@entries + @judging).sort { |a, b| a.timeslot.order <=> b.timeslot.order }
  end

  private
  def assign_next_fair
    @next_fair = next_fair
  end
end
