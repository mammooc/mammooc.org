# -*- encoding : utf-8 -*-
class MoocProvidersController < ApplicationController
  before_action :set_mooc_provider, only: [:show, :edit, :update, :destroy]

  # GET /mooc_providers
  # GET /mooc_providers.json
  def index
    @mooc_providers = MoocProvider.all
  end

  # GET /mooc_providers/1
  # GET /mooc_providers/1.json
  def show
  end

  # GET /mooc_providers/new
  def new
    @mooc_provider = MoocProvider.new
  end

  # GET /mooc_providers/1/edit
  def edit
  end

  # POST /mooc_providers
  # POST /mooc_providers.json
  def create
    @mooc_provider = MoocProvider.new(mooc_provider_params)

    respond_to do |format|
      if @mooc_provider.save
        format.html { redirect_to @mooc_provider, notice: 'Mooc provider was successfully created.' }
        format.json { render :show, status: :created, location: @mooc_provider }
      else
        format.html { render :new }
        format.json { render json: @mooc_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mooc_providers/1
  # PATCH/PUT /mooc_providers/1.json
  def update
    respond_to do |format|
      if @mooc_provider.update(mooc_provider_params)
        format.html { redirect_to @mooc_provider, notice: 'Mooc provider was successfully updated.' }
        format.json { render :show, status: :ok, location: @mooc_provider }
      else
        format.html { render :edit }
        format.json { render json: @mooc_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mooc_providers/1
  # DELETE /mooc_providers/1.json
  def destroy
    @mooc_provider.destroy
    respond_to do |format|
      format.html { redirect_to mooc_providers_url, notice: 'Mooc provider was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mooc_provider
    @mooc_provider = MoocProvider.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mooc_provider_params
    params.require(:mooc_provider).permit(:logo_id, :name, :url, :description)
  end
end
