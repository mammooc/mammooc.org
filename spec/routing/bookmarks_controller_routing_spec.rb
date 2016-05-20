# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BookmarksController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/bookmarks').to route_to('bookmarks#index')
    end

    it 'routes to #create' do
      expect(post: '/bookmarks').to route_to('bookmarks#create')
    end

    it 'routes to #delete' do
      expect(post: '/bookmarks/delete').to route_to('bookmarks#delete')
    end
  end
end
