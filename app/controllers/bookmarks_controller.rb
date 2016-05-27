# frozen_string_literal: true

class BookmarksController < ApplicationController
  respond_to :html

  def index
    @bookmarked_courses = current_user.bookmarks.collect(&:course)
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(@bookmarked_courses)
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.save
    @bookmark.create_activity key: 'bookmark.create', owner: current_user, group_ids: current_user.connected_groups_ids, user_ids: current_user.connected_users_ids
    redirect_to bookmarks_path
  end

  def delete
    bookmark = Bookmark.find_by(user_id: params[:user_id], course_id: params[:course_id])
    bookmark.destroy
    PublicActivity::Activity.find_by(trackable_id: bookmark.id, trackable_type: 'Bookmark', owner: params[:user_id], owner_type: 'User').destroy
    redirect_to bookmarks_path
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:user_id, :course_id)
  end
end
