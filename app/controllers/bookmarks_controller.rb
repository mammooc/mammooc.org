# -*- encoding : utf-8 -*-
class BookmarksController < ApplicationController
  respond_to :html

  def index
    @bookmarked_courses = current_user.bookmarks.collect{ |bookmark| bookmark.course }
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@bookmarked_courses)
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.save
    redirect_to bookmarks_path
  end

  def delete
    Bookmark.find_by(user_id: params[:user_id], course_id: params[:course_id]).destroy
    redirect_to bookmarks_path
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:user_id, :course_id)
  end
end
