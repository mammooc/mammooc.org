# -*- encoding : utf-8 -*-
class BookmarksController < ApplicationController
  respond_to :html

  def index
    bookmarks = current_user.bookmarks
    @bookmarked_courses = []
    bookmarks.each do |bookmark|
      @bookmarked_courses.push bookmark.course
    end
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@bookmarked_courses)
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.save
    redirect_to bookmarks_path
  end

  def delete
    delete_bookmark = Bookmark.find_by(user_id: params[:user_id], course_id: params[:course_id])
    delete_bookmark.destroy
    redirect_to bookmarks_path
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:user_id, :course_id)
  end
end
