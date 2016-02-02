# encoding: utf-8
# frozen_string_literal: true

class UserEmailsController < ApplicationController
  before_action :set_email, only: [:destroy, :mark_as_deleted]

  def mark_as_deleted
    session[:deleted_user_emails] ||= []
    session[:deleted_user_emails].push @user_email.id
    respond_to do |format|
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
