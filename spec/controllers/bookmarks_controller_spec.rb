# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:course) { FactoryBot.create(:course) }
  let(:valid_attributes) { {user_id: user.id, course_id: course.id} }

  before do
    sign_in user
  end

  describe 'GET index' do
    it 'assigns all bookmarks as @bookmarks' do
      bookmark = Bookmark.create! valid_attributes
      get :index
      expect(assigns(:bookmarked_courses)).to eq([bookmark.course])
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Bookmark' do
        expect do
          post :create, params: {bookmark: valid_attributes}
        end.to change(Bookmark, :count).by(1)
      end

      it 'creates a new Bookmark Activity' do
        expect do
          post :create, params: {bookmark: valid_attributes}
        end.to change(PublicActivity::Activity, :count).by(1)
      end

      it 'assigns a newly created bookmark as @bookmark' do
        post :create, params: {bookmark: valid_attributes}
        expect(assigns(:bookmark)).to be_a(Bookmark)
        expect(assigns(:bookmark)).to be_persisted
      end
    end
  end

  describe 'GET delete' do
    it 'destroys the bookmark of specified user and course' do
      bookmark = FactoryBot.create(:bookmark, user: user, course: course)
      FactoryBot.create(:activity_bookmark, trackable_id: bookmark.id, owner_id: user.id)
      expect { post :delete, params: {user_id: user.id, course_id: course.id} }.to change(Bookmark, :count).by(-1)
    end
  end
end
