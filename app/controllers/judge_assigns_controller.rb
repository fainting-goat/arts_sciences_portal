class JudgeAssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin
  before_action :set_judge_assign, only: [:show, :edit, :update, :destroy]
  before_action :set_fair

  # GET /judge_assigns
  # GET /judge_assigns.json
  def index
    @judge_assigns = JudgeAssign.for_fair(@fair.id)
  end

  # GET /judge_assigns/1
  # GET /judge_assigns/1.json
  def show
  end

  # GET /judge_assigns/new
  def new
    @judge_assign = JudgeAssign.new
  end

  # GET /judge_assigns/1/edit
  def edit
  end

  # POST /judge_assigns
  # POST /judge_assigns.json
  def create
    @judge_assign = JudgeAssign.new(judge_assign_params)

    respond_to do |format|
      if @judge_assign.save
        format.html { redirect_to [@fair, @judge_assign], notice: 'Judge assign was successfully created.' }
        format.json { render :show, status: :created, location: @judge_assign }
      else
        format.html { render :new }
        format.json { render json: @judge_assign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /judge_assigns/1
  # PATCH/PUT /judge_assigns/1.json
  def update
    respond_to do |format|
      if @judge_assign.update(judge_assign_params)
        format.html { redirect_to [@fair, @judge_assign], notice: 'Judge assign was successfully updated.' }
        format.json { render :show, status: :ok, location: @judge_assign }
      else
        format.html { render :edit }
        format.json { render json: @judge_assign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /judge_assigns/1
  # DELETE /judge_assigns/1.json
  def destroy
    @judge_assign.destroy
    respond_to do |format|
      format.html { redirect_to fair_judge_assigns_url(@fair), notice: 'Judge assign was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_judge_assign
      @judge_assign = JudgeAssign.find(params[:id])
    end

  def set_fair
    @fair = Fair.find(params[:fair_id])
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def judge_assign_params
      params.require(:judge_assign).permit(:assigned, :shadow, :user_id, :entry_id)
    end
end
