# -*- encoding : utf-8 -*-
class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    bookmarks = current_user.bookmarks
    @bookmarked_courses = []
    bookmarks.each do |bookmark|
      @bookmarked_courses.push bookmark.course
    end
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@bookmarked_courses)
    respond_with(@bookmarks)
  end

  def show
    respond_with(@bookmark)
  end

  def new
    @bookmark = Bookmark.new
    respond_with(@bookmark)
  end

  def edit
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.save
    respond_with(@bookmark)
  end

  def delete
    delete_bookmark = Bookmark.find_by(user_id: params[:user_id], course_id: params[:course_id])
    delete_bookmark.destroy
    redirect_to bookmarks_path
  end

  def update
    @bookmark.update(bookmark_params)
    respond_with(@bookmark)
  end

  def destroy
    @bookmark.destroy
    respond_with(@bookmark)
  end

  private

  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  def bookmark_params
    params.require(:bookmark).permit(:user_id, :course_id)
  end
end
