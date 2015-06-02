# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course) }
  let(:valid_attributes) { {user_id: user.id, course_id: course.id} }

  before(:each) do
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
          post :create, bookmark: valid_attributes
        end.to change(Bookmark, :count).by(1)
      end

      it 'assigns a newly created bookmark as @bookmark' do
        post :create, bookmark: valid_attributes
        expect(assigns(:bookmark)).to be_a(Bookmark)
        expect(assigns(:bookmark)).to be_persisted
      end
    end
  end

  describe 'GET delete' do
    it 'destroys the bookmark of specified user and course' do
      FactoryGirl.create(:bookmark, user: user, course: course)
      expect { post :delete, user_id: user.id, course_id: course.id }.to change(Bookmark, :count).by(-1)
    end
  end
end
