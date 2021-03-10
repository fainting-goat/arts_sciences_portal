class FairsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin
  before_action :set_fair, only: [:show, :edit, :update, :destroy, :schedule, :view_schedule, :submit_schedule, :review, :tallyroom]

  # GET /fairs
  # GET /fairs.json
  def index
    @fairs = Fair.all.in_order
  end

  # GET /fairs/1
  # GET /fairs/1.json
  def show
  end

  # GET /fairs/new
  def new
    @fair = Fair.new
  end

  # GET /fairs/1/edit
  def edit
  end

  # POST /fairs
  # POST /fairs.json
  def create
    @fair = Fair.new(fair_params)

    respond_to do |format|
      if @fair.save
        format.html { redirect_to @fair, notice: 'Fair was successfully created.' }
        format.json { render :show, status: :created, location: @fair }
      else
        format.html { render :new }
        format.json { render json: @fair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fairs/1
  # PATCH/PUT /fairs/1.json
  def update
    respond_to do |format|
      if @fair.update(fair_params)
        format.html { redirect_to @fair, notice: 'Fair was successfully updated.' }
        format.json { render :show, status: :ok, location: @fair }
      else
        format.html { render :edit }
        format.json { render json: @fair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fairs/1
  # DELETE /fairs/1.json
  def destroy
    @fair.destroy
    respond_to do |format|
      format.html { redirect_to fairs_url, notice: 'Fair was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def view_schedule
    @entries = Entry.fair_entries(@fair.id).in_schedule_order
  end

  def schedule
    @selected = Rails.cache.fetch("selected")
    @judges = Rails.cache.fetch("judges")
    @assignments = Rails.cache.fetch("assignments")

    reset if @selected.nil? && @judges.nil? && @assignments.nil?

    @selected = Rails.cache.fetch("selected")
    @judges_selected = Rails.cache.fetch("judges")
    @assignments = Rails.cache.fetch("assignments")

    @entries = Entry.fair_entries(@fair.id).order(:entry_name)
    @judges = User.volunteered(@fair).includes([:judge_assigns, :judge_preferences, :user_peerages])
  end

  def submit_schedule
    update_assignments(params[:judge_assigns])

    Entry.update(params[:entries].keys, params[:entries].values)

    redirect_to schedule_fair_url, notice: 'Schedule was successfully updated.'
  end

  def review
    @divs = Entry.divisions(@fair).sort {|a,b| b.final_score <=> a.final_score}

    # find the ids of all users that don't qualify for pent
    disqualified_entries = Entry.pentathlons(@fair).select { |entry| entry.final_score < 19 }.map{ |entry| entry.id }
    disqualified_users = UserEntry.where(entry_id: disqualified_entries).pluck(:user_id).uniq

    @pents = Entry.qualified_pents(@fair, disqualified_users)

    @entries = (Entry.non_pents(@fair) + Entry.disqualified_pents(@fair, disqualified_users))
                   .sort {|a,b| b.final_score <=> a.final_score}
  end

  def tallyroom
    @scoresheets = Scoresheet.for_fair(@fair)
    @remaining_judges = JudgeAssign.for_fair(@fair.id).reject {|assign| !@scoresheets.find_by(user_id: assign.user_id, entry_id: assign.entry_id).nil? }
    @unjudged_entries = Entry.fair_entries(@fair.id).where(id: @remaining_judges.pluck(:entry_id))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fair
      @fair = Fair.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fair_params
      params.require(:fair).permit(
          :date,
          :region_id,
          :name,
          :comment,
          :internet_access,
          :entries_allowed,
          :scheduling_visible,
          :mail_in_scoresheets_allowed,
          :scoresheets_allowed,
          :finalized,
          :kingdom)
    end

  def update_assignments(judge_assignments)
    # this is so hacky but I give up I'll make this not terrible some other day
    # I miss Elixir
    assignments = {}
    unless judge_assignments.nil?
      judge_assignments.each do |key|
        entry = key.split("_").first
        judge = key.split("_").last.to_i
        assignments.has_key?(entry) ? assignments[entry].push(judge) : assignments[entry] = [judge]
      end
    end

    Entry.where(fair_id: @fair.id).each do |entry|
      selections = assignments.has_key?(entry.id) ? assigments[entry.id] : []
      JudgeAssign.where(entry_id: entry.id).each do |judge|
        judge.destroy unless selections.include?(judge.user_id)
      end
    end

    assignments.each do |entry, selections|
      selections.each do |new_judge|
        JudgeAssign.create(user_id: new_judge, entry_id: entry) if JudgeAssign.find_by(user_id: new_judge, entry_id: entry).nil?
      end
    end
  end

  # this is duplicated code
  def reset
    fair = @fair

    selected = {}
    Entry.fair_entries(fair).each { |x| selected[x.id.to_s] = x.timeslot_id.to_s unless x.timeslot_id.nil? }

    judges = {}
    JudgeAssign.for_fair(fair).each do |x|
      if judges.has_key?(x.entry_id.to_s)
        judges[x.entry_id.to_s].push(x.user_id.to_s)
      else
        judges[x.entry_id.to_s] = [x.user_id.to_s]
      end
    end

    assignments = {}

    selected.each do |entry, timeslot|
      people = UserEntry.where(entry_id: entry).pluck(:user_id)
      people.each do |person|
        timeslot_entry = {entry: entry, timeslot: timeslot, as: 'entrant'}

        if assignments.has_key?(person.to_s)
          assignments[person.to_s].push(timeslot_entry)
        else
          assignments[person.to_s] = [timeslot_entry]
        end
      end

      unless judges[entry].nil?
        judge_entry = {entry: entry, timeslot: timeslot, as: 'judge'}

        judges[entry].each do |judge|
          if assignments.has_key?(judge)
            assignments[judge].push(judge_entry)
          else
            assignments[judge] = [judge_entry]
          end
        end
      end
    end

    Rails.cache.write("selected", selected)
    Rails.cache.write("judges", judges)
    Rails.cache.write("assignments", assignments)
  end
end
