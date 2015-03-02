class HomeController < ApplicationController
  skip_before_action :require_login

  def index
    @news_email = NewsEmail.new
  end

  def create
    @news_email = NewsEmail.new(news_email_params)
    respond_to do |format|
      if @news_email.save
        format.html { redirect_to root_path, notice: t('startpage.registration_news_email.success') }
      else
        format.html { redirect_to root_path, :flash => {:error => @news_email.errors.full_messages.to_sentence} }
      end
    end
  end

  def news_email_params
    params.require(:news_email).permit(:email)
  end
end
