include FairsHelper

class TallyroomController < ApplicationController
  def index
    fair = next_fair
    @unjudged_entries = filter_admin_unjudged(Entry.fair_entries(fair))
    @scoresheets = Scoresheet.for_fair(fair)
    # @remaining_judges = JudgeAssign.where.not(entry_id: @scoresheets.pluck(:entry_id), user_id: @scoresheets.pluck(:user_id))
    @remaining_judges = JudgeAssign.for_fair(fair).reject {|assign| !@scoresheets.find_by(user_id: assign.user_id, entry_id: assign.entry_id).nil? }
  end

  # GET /scoresheets/1
  # GET /scoresheets/1.json
  def show
  end

  # GET /scoresheets/new
  def new
    @scoresheet = Scoresheet.new

    CriteriaType.applicable(@entry.category).each do |criteria_type|
      @scoresheet.scores.build({criteria_type_id: criteria_type.id})
    end

    CriteriaType.all.top_level.each do |criteria_type|
      @scoresheet.scores.build({criteria_type_id: criteria_type.id})
    end
  end

  # GET /scoresheets/1/edit
  def edit
  end

  # POST /scoresheets
  # POST /scoresheets.json
  def create
    @scoresheet = Scoresheet.new(scoresheet_params)

    CriteriaType.applicable(@entry.category).each do |criteria_type|
      @scoresheet.scores.build({criteria_type_id: criteria_type.id})
    end

    CriteriaType.all.top_level.each do |criteria_type|
      @scoresheet.scores.build({criteria_type_id: criteria_type.id})
    end

    update_scores

    respond_to do |format|
      if @scoresheet.save
        format.html { redirect_to [@scoresheet.entry, @scoresheet], notice: 'Scoresheet was successfully created.' }
        format.json { render :show, status: :created, location: @scoresheet }
      else
        format.html { render :new }
        format.json { render json: [@scoresheet.entry, @scoresheet.error], status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scoresheets/1
  # PATCH/PUT /scoresheets/1.json
  def update
    Score.update(params[:scoresheet][:scores].keys, params[:scoresheet][:scores].values)

    respond_to do |format|
      if @scoresheet.update(scoresheet_params)
        format.html { redirect_to [@scoresheet.entry, @scoresheet], notice: 'Scoresheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @scoresheet }
      else
        format.html { render :edit }
        format.json { render json: [@scoresheet.entry, @scoresheet].errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scoresheets/1
  # DELETE /scoresheets/1.json
  def destroy
    @scoresheet.destroy
    respond_to do |format|
      format.html { redirect_to scoresheets_url, notice: 'Scoresheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scoresheet
      @scoresheet = Scoresheet.find(params[:id])
    end

  def set_entry
    @entry = Entry.find(params[:entry_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scoresheet_params
    if current_user.admin?
      params.permit(:entry_id).merge(user_id: params[:scoresheet][:user_id])
    else
      params.permit(:entry_id).merge(user_id: current_user.id)
    end
  end

  def score_params(params)
    params.permit(:criteria_type, :score, :comment)
  end

  def update_scores
    scores = params[:scoresheet][:scores]

    scores.each do |score|
      score_record = @scoresheet.scores.select{|n| n.criteria_type_id == score[:criteria_type_id].to_i}.first
      score_record.update(score_params(score))
      score_record.save
    end
  end

  def filter_unjudged(entries)
    entries.reject do |entry|
      !Scoresheet.find_by(entry_id: entry.id, user_id: current_user.id).nil?
    end
  end

  def filter_admin_unjudged(entries)
    entries.reject do |entry|
      JudgeAssign.where(entry_id: entry.id).count == Scoresheet.where(entry_id: entry.id).count
    end
  end
end
