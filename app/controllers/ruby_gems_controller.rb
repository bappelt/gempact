class RubyGemsController < ApplicationController
  before_action :set_ruby_gem, only: [:show, :edit, :update, :destroy]

  # GET /ruby_gems
  # GET /ruby_gems.json
  def index
    @ruby_gems = RubyGem.take(50)
  end

  # GET /ruby_gems/1
  # GET /ruby_gems/1.json
  def show
  end

  # GET /ruby_gems/new
  def new
    @ruby_gem = RubyGem.new
  end

  # GET /ruby_gems/1/edit
  def edit
  end

  # POST /ruby_gems
  # POST /ruby_gems.json
  def create
    @ruby_gem = RubyGem.new(ruby_gem_params)

    respond_to do |format|
      if @ruby_gem.save
        format.html { redirect_to @ruby_gem, notice: 'Ruby gem was successfully created.' }
        format.json { render :show, status: :created, location: @ruby_gem }
      else
        format.html { render :new }
        format.json { render json: @ruby_gem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ruby_gems/1
  # PATCH/PUT /ruby_gems/1.json
  def update
    respond_to do |format|
      if @ruby_gem.update(ruby_gem_params)
        format.html { redirect_to @ruby_gem, notice: 'Ruby gem was successfully updated.' }
        format.json { render :show, status: :ok, location: @ruby_gem }
      else
        format.html { render :edit }
        format.json { render json: @ruby_gem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ruby_gems/1
  # DELETE /ruby_gems/1.json
  def destroy
    @ruby_gem.destroy
    respond_to do |format|
      format.html { redirect_to ruby_gems_url, notice: 'Ruby gem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ruby_gem
      @ruby_gem = RubyGem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ruby_gem_params
      params[:ruby_gem]
    end
end
