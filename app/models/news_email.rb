class NewsEmail < ActiveRecord::Base
  validates :email, :uniqueness => {:message => I18n.t('startpage.registration_news_email.already_registered')}
end
