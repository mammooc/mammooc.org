# -*- encoding : utf-8 -*-
class UserEmailsController < ApplicationController
  before_action :set_email, only: [:update, :destroy, :mark_as_deleted]

  # POST /user_emails
  # POST /user_emails.json
  def create
    @user_email = UserEmail.new(email_params)

    respond_to do |format|
      if @user_email.save
        format.html { redirect_to @user_email, notice: 'Email was successfully created.' }
        format.json { render :show, status: :created, location: @user_email }
      else
        format.html { render :new }
        format.json { render json: @user_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_emails/1
  # PATCH/PUT /user_emails/1.json
  def update
    respond_to do |format|
      if @user_email.update(email_params)
        format.html { redirect_to @user_email, notice: 'Email was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_email }
      else
        format.html { render :edit }
        format.json { render json: @user_email.errors, status: :unprocessable_entity }
      end
    end
  end

  def mark_as_deleted
    session[:deleted_user_emails] ||= []
    session[:deleted_user_emails].push @user_email.id
    respond_to do |format|
      format.json { render json: {status: :ok} }
    end
  end

  # DELETE /user_emails/1
  # DELETE /user_emails/1.json
  def destroy
    @user_email.destroy
    respond_to do |format|
      format.html { redirect_to user_emails_url, notice: 'Email was successfully destroyed.' }
      format.json { render json: {status: :ok} }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_email
    @user_email = UserEmail.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def email_params
    params.require(:user_email).permit(:address, :is_primary, :user_id)
  end
end
