# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:course) { FactoryGirl.create(:course) }
  let(:valid_attributes) { {user_id: user.id, course_id: course.id}}


  before(:each) do
    sign_in user
  end

  describe 'GET index' do
    it 'assigns all bookmarks as @bookmarks' do
      bookmark = Bookmark.create! valid_attributes
      get :index
      expect(assigns(:bookmarks)).to eq([bookmark])
    end
  end

  describe 'GET show' do
    it 'assigns the requested bookmark as @bookmark' do
      bookmark = Bookmark.create! valid_attributes
      get :show, {id: bookmark.to_param}
      expect(assigns(:bookmark)).to eq(bookmark)
    end
  end

  describe 'GET new' do
    it 'assigns a new bookmark as @bookmark' do
      get :new, {}
      expect(assigns(:bookmark)).to be_a_new(Bookmark)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested bookmark as @bookmark' do
      bookmark = Bookmark.create! valid_attributes
      get :edit, {id: bookmark.to_param}
      expect(assigns(:bookmark)).to eq(bookmark)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Bookmark' do
        expect do
          post :create, {bookmark: valid_attributes}
        end.to change(Bookmark, :count).by(1)
      end

      it 'assigns a newly created bookmark as @bookmark' do
        post :create, {bookmark: valid_attributes}
        expect(assigns(:bookmark)).to be_a(Bookmark)
        expect(assigns(:bookmark)).to be_persisted
      end

      it 'redirects to the created bookmark' do
        post :create, {bookmark: valid_attributes}
        expect(response).to redirect_to(Bookmark.last)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested bookmark' do
        bookmark = Bookmark.create! valid_attributes
        put :update, {id: bookmark.to_param, bookmark: new_attributes}
        bookmark.reload
        skip('Add assertions for updated state')
      end

      it 'assigns the requested bookmark as @bookmark' do
        bookmark = Bookmark.create! valid_attributes
        put :update, {id: bookmark.to_param, bookmark: valid_attributes}
        expect(assigns(:bookmark)).to eq(bookmark)
      end

      it 'redirects to the bookmark' do
        bookmark = Bookmark.create! valid_attributes
        put :update, {id: bookmark.to_param, bookmark: valid_attributes}
        expect(response).to redirect_to(bookmark)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested bookmark' do
      bookmark = Bookmark.create! valid_attributes
      expect do
        delete :destroy, {id: bookmark.to_param}
      end.to change(Bookmark, :count).by(-1)
    end

    it 'redirects to the bookmarks list' do
      bookmark = Bookmark.create! valid_attributes
      delete :destroy, {id: bookmark.to_param}
      expect(response).to redirect_to(bookmarks_url)
    end
  end

  describe 'GET delete' do
    it 'should destroy the bookmark of specified user and course' do
      FactoryGirl.create(:bookmark, user: user, course: course)
      expect { get :delete, {user_id: user.id, course_id: course.id} }.to change(Bookmark, :count).by(-1)
    end
  end

end
