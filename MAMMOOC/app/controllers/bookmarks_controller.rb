class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @bookmarks = Bookmark.all
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
