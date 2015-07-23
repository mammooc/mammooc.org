# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }
  let!(:primary_email) { FactoryGirl.create(:user_email, user: user, is_primary: true) }
  let(:another_user) { FactoryGirl.create :user }

  let!(:course_enrollments_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_enrollments_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:course_results_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_results_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:course_progress_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :course_progress_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end
  let!(:profile_visibility_settings) do
    setting = FactoryGirl.create :user_setting, name: :profile_visibility, user: user
    FactoryGirl.create :user_setting_entry, key: :groups, value: [], setting: setting
    FactoryGirl.create :user_setting_entry, key: :users, value: [], setting: setting
    setting
  end

  let!(:open_hpi) { FactoryGirl.create(:mooc_provider, name: 'openHPI', api_support_state: :naive) }
  let!(:open_sap) { FactoryGirl.create(:mooc_provider, name: 'openSAP', api_support_state: :naive) }
  let!(:coursera) { FactoryGirl.create(:mooc_provider, name: 'coursera', api_support_state: :oauth) }
  let!(:other_mooc_provider) { FactoryGirl.create(:mooc_provider) }

  before(:each) do
    sign_in user
  end

  describe 'GET show' do
    it 'assigns the requested user as @user' do
      get :show, id: user.to_param
      expect(assigns(:user)).to eq(user)
    end

    context 'without authorization' do
      before(:each) { get :show, id: another_user.id }
      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'shows an alert message' do
        expect(flash[:alert]).to eq I18n.t('unauthorized.show.user')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      self.use_transactional_fixtures = false

      before(:all) do
        DatabaseCleaner.strategy = :truncation
      end

      after(:all) do
        DatabaseCleaner.strategy = :transaction
      end

      let(:new_attributes) { {first_name: 'Maxim', last_name: 'Mustergender', primary_email: 'maxim.mustergender@example.com'} }

      it 'updates the requested user' do
        put :update, id: user.to_param, user: new_attributes
        user.reload
        expect(user.first_name).to eq('Maxim')
        expect(user.last_name).to eq('Mustergender')
        expect(user.primary_email).to eq('maxim.mustergender@example.com')
        expect(flash[:notice]).to eq I18n.t('flash.notice.users.successfully_updated')
      end

      it 'assigns the requested user as @user' do
        put :update, id: user.to_param, user: FactoryGirl.attributes_for(:user)
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        put :update, id: user.to_param, user: FactoryGirl.attributes_for(:user)
        expect(response).to redirect_to(user)
      end
    end

    context 'without authorization' do
      before(:each) { put :update, id: another_user.id, name: 'Another' }
      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'shows an alert message' do
        expect(flash[:alert]).to eq I18n.t('unauthorized.update.user')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested user' do
      expect { delete :destroy, id: user.to_param }.to change { User.count }.by(-1)
    end

    it 'deletes group memberships when deleting a user' do
      created_group = FactoryGirl.create(:group, users: [user])
      group = Group.find(created_group.id)
      delete :destroy, id: user.to_param
      expect(group.users).not_to include(user)
    end

    it 'redirects to the users list and shows a flash message' do
      delete :destroy, id: user.to_param
      expect(response).to redirect_to(users_url)
      expect(flash[:notice]).to eq I18n.t('flash.notice.users.successfully_destroyed')
    end

    context 'without authorization' do
      before(:each) { delete :destroy, id: another_user.id }
      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'shows an alert message' do
        expect(flash[:alert]).to eq I18n.t('unauthorized.destroy.user')
      end
    end
  end

  describe 'GET synchronize_courses' do
    render_views
    let(:json) { JSON.parse(response.body) }

    let!(:open_hpi_connection) { FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: open_hpi) }
    let!(:open_sap_connection) { FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: open_sap) }
    let!(:coursera_connection) { FactoryGirl.create(:oauth_mooc_provider_user, user: user, mooc_provider: coursera) }

    it 'synchronizes all available user data and redirects to the dashboard_path' do
      expect_any_instance_of(OpenHPIUserWorker).to receive(:perform).with([user.id])
      expect_any_instance_of(OpenSAPUserWorker).to receive(:perform).with([user.id])
      expect_any_instance_of(CourseraUserWorker).to receive(:perform).with([user.id])
      get :synchronize_courses, id: user.to_param
      expect(response).to redirect_to(dashboard_path)
    end

    it 'synchronizes all available user data and renders a partial as JSON' do
      expect_any_instance_of(OpenHPIUserWorker).to receive(:perform).with([user.id]).and_return(true)
      expect_any_instance_of(OpenSAPUserWorker).to receive(:perform).with([user.id]).and_return(true)
      expect_any_instance_of(CourseraUserWorker).to receive(:perform).with([user.id]).and_return(true)
      get :synchronize_courses, format: :json, id: user.to_param
      expect(assigns(:synchronization_state)[:openHPI]).to eql true
      expect(assigns(:synchronization_state)[:openSAP]).to eql true
      expect(assigns(:synchronization_state)[:coursera]).to eql true
      expected_json = JSON.parse '{"partial":"No courses available","synchronization_state":{"openHPI":true,"openSAP":true,"coursera":true}}'
      expect(json).to eql expected_json
    end
  end

  describe 'GET settings' do
    it 'prepares settings page' do
      allow_any_instance_of(ActionController::RequestForgeryProtection).to receive(:masked_authenticity_token).and_return('my_csrf_token')
      get :settings, id: user
      assigns(:mooc_providers).each_with_index do |mooc_provider, index|
        expect(mooc_provider[:id]).to eql MoocProvider.all[index].id
        expect(mooc_provider[:logo_id]).to eql MoocProvider.all[index].logo_id
        expect(mooc_provider[:api_support_state]).to eql MoocProvider.all[index].api_support_state
        if MoocProvider.all[index].name == 'coursera'
          oauth_link = CourseraConnector.new.oauth_link("#{user_settings_path(user)}?subsite=mooc_provider", 'my_csrf_token')
          expect(mooc_provider[:oauth_link]).to eql oauth_link
        end
      end
      expect(assigns(:mooc_provider_connections)).to eql user.mooc_providers.pluck(:mooc_provider_id)

      # privacy settings
      expect(assigns(:course_enrollments_visibility_groups)).to eql course_enrollments_visibility_settings.value(:groups)
      expect(assigns(:course_enrollments_visibility_users)).to eql course_enrollments_visibility_settings.value(:users)
      expect(assigns(:course_results_visibility_groups)).to eql course_results_visibility_settings.value(:groups)
      expect(assigns(:course_results_visibility_users)).to eql course_results_visibility_settings.value(:users)
      expect(assigns(:course_progress_visibility_groups)).to eql course_progress_visibility_settings.value(:groups)
      expect(assigns(:course_progress_visibility_users)).to eql course_progress_visibility_settings.value(:users)
      expect(assigns(:profile_visibility_groups)).to eql profile_visibility_settings.value(:groups)
      expect(assigns(:profile_visibility_users)).to eql profile_visibility_settings.value(:users)
    end

    it 'reset session variable for emails marked as deleted' do
      session[:deleted_user_emails] = [primary_email.id]
      get :settings, id: user.id
      expect(session).not_to have_key(:deleted_user_emails)
    end

    it 'assigns sorted user_emails to @emails' do
      second_email = FactoryGirl.create(:user_email, address: 'aaaa@example.com', user: user, is_primary: false)
      third_email = FactoryGirl.create(:user_email, address: 'bbbbb@example.com', user: user, is_primary: false)
      get :settings, id: user.id
      expect(assigns(:emails)).to match_array([primary_email, second_email, third_email])
    end
  end

  describe 'GET oauth_callback' do
    it 'handles a positive response' do
      allow_any_instance_of(ActionController::RequestForgeryProtection).to receive(:valid_authenticity_token?).and_return(true)
      expect_any_instance_of(CourseraConnector).to receive(:initialize_connection).with(user, code: 'abc123').and_return(true)
      get :oauth_callback, code: 'abc123', state: 'coursera~/dashboard~my_csrf_token'
      expect(response).to redirect_to(dashboard_path)
    end

    it 'handles a negative response' do
      allow_any_instance_of(ActionController::RequestForgeryProtection).to receive(:valid_authenticity_token?).and_return(true)
      expect_any_instance_of(CourseraConnector).to receive(:destroy_connection).with(user).and_return(true)
      get :oauth_callback, error: 'access_denied', state: 'coursera~/dashboard~my_csrf_token'
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include(I18n.t('users.synchronization.oauth_error'))
    end

    it 'handles a negative response without state' do
      allow_any_instance_of(ActionController::RequestForgeryProtection).to receive(:valid_authenticity_token?).and_return(true)
      get :oauth_callback, error: 'access_denied'
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include(I18n.t('users.synchronization.oauth_error'))
    end

    it 'handles unknown mooc provider' do
      expect_any_instance_of(ConnectorMapper).not_to receive(:get_connector_by_mooc_provider)
      get :oauth_callback, code: 'abc123', state: 'unknown~/dashboard~my_csrf_token'
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include(I18n.t('users.synchronization.oauth_error'))
    end

    it 'handles mooc provider which does not support oauth' do
      expect_any_instance_of(ConnectorMapper).to receive(:get_connector_by_mooc_provider)
      get :oauth_callback, code: 'abc123', state: 'openHPI~/dashboard~my_csrf_token'
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include(I18n.t('users.synchronization.oauth_error'))
    end

    it 'handles invalid csrf token' do
      allow_any_instance_of(ActionController::RequestForgeryProtection).to receive(:valid_authenticity_token?).and_return(false)
      expect_any_instance_of(ConnectorMapper).to receive(:get_connector_by_mooc_provider).and_return(CourseraConnector.new)
      get :oauth_callback, code: 'abc123', state: 'coursera~/dashboard~my_invalid_csrf_token'
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include(I18n.t('users.synchronization.oauth_error'))
    end
  end

  describe 'GET set_mooc_provider_connection' do
    render_views
    let(:json) { JSON.parse(response.body) }
    let(:email_address) { 'user@example.com' }
    let(:password) { 'p@ssw0rd' }

    it 'handles unknown mooc provider and redirects to the dashboard path' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:initialize_connection)
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:load_user_data).with([user.id])
      get :set_mooc_provider_connection, id: user.to_param, email: email_address, password: password, mooc_provider: 'unknown'
      expect(assigns(:got_connection)).to eql false
      expect(response).to redirect_to(dashboard_path)
    end

    it 'handles unknown mooc provider and renders a partial as JSON' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:initialize_connection)
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:load_user_data).with([user.id])
      get :set_mooc_provider_connection, format: :json, id: user.to_param, email: email_address, password: password, mooc_provider: 'unknown'
      expect(assigns(:got_connection)).to eql false
      expect(json).to include 'partial'
      expect(json['status']).to eql false
    end

    it 'handles unknown mooc provider connector and redirects to the dashboard path' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:initialize_connection)
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:load_user_data).with([user.id])
      get :set_mooc_provider_connection, id: user.to_param, email: email_address, password: password, mooc_provider: other_mooc_provider.to_param
      expect(assigns(:got_connection)).to eql false
      expect(response).to redirect_to(dashboard_path)
    end

    it 'handles unknown mooc provider connector and renders a partial as JSON' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:initialize_connection)
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:load_user_data).with([user.id])
      get :set_mooc_provider_connection, format: :json, id: user.to_param, email: email_address, password: password, mooc_provider: other_mooc_provider.to_param
      expect(assigns(:got_connection)).to eql false
      expect(json).to include 'partial'
      expect(json['status']).to eql false
    end

    context 'openHPI' do
      it 'initializes a new connection to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenHPIConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(true)
        get :set_mooc_provider_connection, id: user.to_param, email: email_address, password: password, mooc_provider: open_hpi.to_param
        expect(assigns(:got_connection)).to eql true
        expect(response).to redirect_to(dashboard_path)
      end

      it 'initializes a new connection to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenHPIConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(true)
        get :set_mooc_provider_connection, format: :json, id: user.to_param, email: email_address, password: password, mooc_provider: open_hpi.to_param
        expect(assigns(:got_connection)).to eql true
        expect(json).to include 'partial'
        expect(json['status']).to eql true
      end

      it 'does not initialize a new connection to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenHPIConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(false)
        get :set_mooc_provider_connection, id: user.to_param, email: email_address, password: password, mooc_provider: open_hpi.to_param
        expect(assigns(:got_connection)).to eql false
        expect(response).to redirect_to(dashboard_path)
      end

      it 'does not initialize a new connection to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenHPIConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(false)
        get :set_mooc_provider_connection, format: :json, id: user.to_param, email: email_address, password: password, mooc_provider: open_hpi.to_param
        expect(assigns(:got_connection)).to eql false
        expect(json).to include 'partial'
        expect(json['status']).to eql false
      end
    end

    context 'openSAP' do
      it 'initializes a new connection to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenSAPConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(true)
        get :set_mooc_provider_connection, id: user.to_param, email: email_address, password: password, mooc_provider: open_sap.to_param
        expect(assigns(:got_connection)).to eql true
        expect(response).to redirect_to(dashboard_path)
      end

      it 'initializes a new connection to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenSAPConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(true)
        get :set_mooc_provider_connection, format: :json, id: user.to_param, email: email_address, password: password, mooc_provider: open_sap.to_param
        expect(assigns(:got_connection)).to eql true
        expect(json).to include 'partial'
        expect(json['status']).to eql true
      end

      it 'does not initialize a new connection to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenSAPConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(false)
        get :set_mooc_provider_connection, id: user.to_param, email: email_address, password: password, mooc_provider: open_sap.to_param
        expect(assigns(:got_connection)).to eql false
        expect(response).to redirect_to(dashboard_path)
      end

      it 'does not initialize a new connection to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenSAPConnector).to receive(:initialize_connection).with(user, email: email_address, password: password).and_return(false)
        get :set_mooc_provider_connection, format: :json, id: user.to_param, email: email_address, password: password, mooc_provider: open_sap.to_param
        expect(assigns(:got_connection)).to eql false
        expect(json).to include 'partial'
        expect(json['status']).to eql false
      end
    end
  end

  describe 'GET revoke_mooc_provider_connection' do
    render_views
    let(:json) { JSON.parse(response.body) }

    it 'handles unknown mooc provider and redirects to the dashboard path' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:destroy_connection).with(user.id)
      get :revoke_mooc_provider_connection, id: user.to_param, mooc_provider: 'unknown'
      expect(assigns(:revoked_connection)).to eql true
      expect(response).to redirect_to(dashboard_path)
    end

    it 'handles unknown mooc provider and renders a partial as JSON' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:destroy_connection)
      get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: 'unknown'
      expect(assigns(:revoked_connection)).to eql true
      expect(json).to include 'partial'
      expect(json['status']).to eql true
    end

    it 'handles unknown mooc provider connector and redirects to the dashboard path' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:destroy_connection)
      get :revoke_mooc_provider_connection, id: user.to_param, mooc_provider: other_mooc_provider.to_param
      expect(assigns(:revoked_connection)).to eql true
      expect(response).to redirect_to(dashboard_path)
    end

    it 'handles unknown mooc provider connector and renders a partial as JSON' do
      expect_any_instance_of(AbstractMoocProviderConnector).not_to receive(:destroy_connection)
      get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: other_mooc_provider.to_param
      expect(assigns(:revoked_connection)).to eql true
      expect(json).to include 'partial'
      expect(json['status']).to eql true
    end

    context 'openHPI' do
      it 'destroys a connection to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenHPIConnector).to receive(:destroy_connection).with(user).and_return(true)
        get :revoke_mooc_provider_connection, id: user.to_param, mooc_provider: open_hpi.to_param
        expect(assigns(:revoked_connection)).to eql true
        expect(response).to redirect_to(dashboard_path)
      end

      it 'destroys a connection to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenHPIConnector).to receive(:destroy_connection).with(user).and_return(true)
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_hpi.to_param
        expect(assigns(:revoked_connection)).to eql true
        expect(json).to include 'partial'
        expect(json['status']).to eql true
      end

      it 'does not try to destroy a connection which is not present (any more) to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenHPIConnector).to receive(:destroy_connection).with(user).and_return(false)
        get :revoke_mooc_provider_connection, id: user.to_param, mooc_provider: open_hpi.to_param
        expect(assigns(:revoked_connection)).to eql false
        expect(response).to redirect_to(dashboard_path)
      end

      it 'does not try to destroy a connection which is not present (any more) to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenHPIConnector).to receive(:destroy_connection).with(user).and_return(false)
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_hpi.to_param
        expect(assigns(:revoked_connection)).to eql false
        expect(json).to include 'partial'
        expect(json['status']).to eql false
      end

      it 'does not try to destroy a connection twice' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: open_hpi)
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_hpi.to_param
        expect(assigns(:revoked_connection)).to eql true
        expect(json).to include 'partial'
        expect(json['status']).to eql true
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_hpi.to_param
        expect(assigns(:revoked_connection)).to eql false
        expect(JSON.parse response.body).to include 'partial'
        expect((JSON.parse response.body)['status']).to eql false
      end
    end

    context 'openSAP' do
      it 'initializes a new connection to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenSAPConnector).to receive(:destroy_connection).with(user).and_return(true)
        get :revoke_mooc_provider_connection, id: user.to_param, mooc_provider: open_sap.to_param
        expect(assigns(:revoked_connection)).to eql true
        expect(response).to redirect_to(dashboard_path)
      end

      it 'initializes a new connection to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenSAPConnector).to receive(:destroy_connection).with(user).and_return(true)
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_sap.to_param
        expect(assigns(:revoked_connection)).to eql true
        expect(json).to include 'partial'
        expect(json['status']).to eql true
      end

      it 'does not try to destroy a connection which is not present (any more) to a naive mooc provider and redirects to the dashboard path' do
        expect_any_instance_of(OpenSAPConnector).to receive(:destroy_connection).with(user).and_return(false)
        get :revoke_mooc_provider_connection, id: user.to_param, mooc_provider: open_sap.to_param
        expect(assigns(:revoked_connection)).to eql false
        expect(response).to redirect_to(dashboard_path)
      end

      it 'does not try to destroy a connection which is not present (any more) to a naive mooc provider and renders a partial as JSON' do
        expect_any_instance_of(OpenSAPConnector).to receive(:destroy_connection).with(user).and_return(false)
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_sap.to_param
        expect(assigns(:revoked_connection)).to eql false
        expect(json).to include 'partial'
        expect(json['status']).to eql false
      end

      it 'does not try to destroy a connection twice' do
        FactoryGirl.create(:naive_mooc_provider_user, user: user, mooc_provider: open_sap)
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_sap.to_param
        expect(assigns(:revoked_connection)).to eql true
        expect(json).to include 'partial'
        expect(json['status']).to eql true
        get :revoke_mooc_provider_connection, format: :json, id: user.to_param, mooc_provider: open_sap.to_param
        expect(assigns(:revoked_connection)).to eql false
        expect(JSON.parse response.body).to include 'partial'
        expect((JSON.parse response.body)['status']).to eql false
      end
    end
  end

  describe 'GET account_settings' do
    it 'does not prepare mooc_provider_settings' do
      expect_any_instance_of(described_class).not_to receive(:prepare_mooc_provider_settings)
      get :account_settings, id: user.to_param
    end

    context 'views' do
      render_views
      let(:json) { JSON.parse(response.body) }

      it 'redirects to the dashboard' do
        get :account_settings, id: user.to_param
        expect(response).to redirect_to dashboard_path
      end

      it 'renders a JSON with the partial' do
        get :account_settings, id: user.to_param, format: :json
        expect(json).to include 'partial'
      end
    end
  end

  describe 'GET mooc_provider_settings' do
    it 'prepares mooc_provider_settings' do
      expect_any_instance_of(described_class).to receive(:prepare_mooc_provider_settings)
      get :mooc_provider_settings, id: user.to_param
    end

    context 'views' do
      render_views
      let(:json) { JSON.parse(response.body) }

      it 'redirects to the dashboard' do
        get :mooc_provider_settings, id: user.to_param
        expect(response).to redirect_to dashboard_path
      end

      it 'renders a JSON with the partial' do
        get :mooc_provider_settings, id: user.to_param, format: :json
        expect(json).to include 'partial'
      end
    end
  end

  describe 'GET privacy_settings' do
    it 'prepares mooc_provider_settings' do
      expect_any_instance_of(described_class).to receive(:prepare_privacy_settings)
      get :privacy_settings, id: user.to_param
    end

    context 'views' do
      render_views
      let(:json) { JSON.parse(response.body) }

      it 'redirects to the dashboard' do
        get :privacy_settings, id: user.to_param
        expect(response).to redirect_to dashboard_path
      end

      it 'renders a JSON with the partial' do
        get :privacy_settings, id: user.to_param, format: :json
        expect(json).to include 'partial'
      end
    end
  end

  describe 'POST set_setting' do
    let(:old_value) { course_enrollments_visibility_settings.value(:groups) }
    let(:new_value) { [FactoryGirl.create(:group).id] }
    subject { ->  { post :set_setting, id: user.id, setting: course_enrollments_visibility_settings.name, key: :groups, value: new_value, format: :json } }

    it 'updates the setting entry' do
      expect { subject.call }.to change { course_enrollments_visibility_settings.value(:groups) }.from(old_value).to(new_value)
    end
  end

  describe 'cancel change email' do
    it 'reset session variable for email marked as deleted' do
      session[:deleted_user_emails] = user.emails.collect(&:id)
      get :cancel_change_email, id: user.id
      expect(session).not_to have_key(:deleted_user_emails)
    end

    it 'redirects to account settings page' do
      get :cancel_change_email, id: user.id
      expect(response).to redirect_to "#{user_settings_path(user)}?subsite=account"
    end
  end

  describe 'change email' do
    let!(:second_email) { FactoryGirl.create(:user_email, user: user, is_primary: false) }

    it 'reset session variable for email marked as deleted' do
      session[:deleted_user_emails] = user.emails.collect(&:id)
      get :change_email, id: user.id, user: {user_email: {is_primary: primary_email.id}}
      expect(session).not_to have_key(:deleted_user_emails)
    end

    it 'change existing email address' do
      get :change_email, id: user.id, user: {user_email: {"address_#{second_email.id}": 'newAddress@example.com', is_primary: primary_email.id}}
      second_email.reload
      expect(second_email.address).to eq 'newAddress@example.com'
      expect(UserEmail.find(primary_email.id).address).to eq primary_email.address
    end

    it 'change existing primary email' do
      get :change_email, id: user.id, user: {user_email: {is_primary: second_email.id}}
      second_email.reload
      primary_email.reload
      expect(second_email.is_primary).to be true
      expect(primary_email.is_primary).to be false
    end

    it 'adds new email address' do
      get :change_email, id: user.id, user: {user_email: {address_3: 'this_is_a_new_email@example.com', is_primary: primary_email.id}, index: 3}
      expect(UserEmail.where(user: user).length).to eq 3
      expect(UserEmail.find_by(address: 'this_is_a_new_email@example.com', user: user).is_primary).to be false
    end

    it 'adds new email address and makes it primary' do
      get :change_email, id: user.id, user: {user_email: {address_3: 'this_is_a_new_email@example.com', is_primary: 'new_email_index_3'}, index: 3}
      expect(UserEmail.find_by(address: 'this_is_a_new_email@example.com', user: user).is_primary).to be true
    end

    it 'deletes emails defined in session variable' do
      session[:deleted_user_emails] = [second_email.id]
      get :change_email, id: user.id, user: {user_email: {is_primary: primary_email.id}}
      expect(UserEmail.where(id: second_email.id)).to be_empty
    end

    it 'updates existing, change primary, add new emails and delete specified emails' do
      third_email = FactoryGirl.create(:user_email, user: user, is_primary: false)
      session[:deleted_user_emails] = [second_email.id]
      get :change_email, id: user.id, user: {user_email: {address_4: 'this_is_a_new_email@example.com', address_5: 'this_is_another_new_email@example.com', "address_#{third_email.id}": 'newAddress@example.com', is_primary: third_email.id}, index: 5}
      expect(UserEmail.where(user: user).length).to eq 4
      expect(UserEmail.where(id: second_email.id)).to be_empty
      expect(UserEmail.find_by(address: 'this_is_a_new_email@example.com', user: user).is_primary).to be false
      expect(UserEmail.find_by(address: 'this_is_another_new_email@example.com', user: user).is_primary).to be false
      expect(UserEmail.find(third_email.id).is_primary).to be true
      expect(UserEmail.find(primary_email.id).is_primary).to be false
      expect(UserEmail.find(third_email.id).address).to eq 'newAddress@example.com'
      expect(UserEmail.find(primary_email.id).address).to eq primary_email.address
    end
  end

  describe 'GET completions' do
    let(:course) { FactoryGirl.create(:course) }

    let(:valid_attributes) do
      {user: user, course: course}
    end

    it 'assigns all completions as @completions' do
      completion = Completion.create! valid_attributes
      get :completions, id: user
      expect(assigns(:completions)).to eq([completion])
    end
  end
end
