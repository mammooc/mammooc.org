# encoding: utf-8
# frozen_string_literal: true

def achievement_type?(tracks, type_of_achievement)
  return true if (tracks.collect {|t| t.track_type.type_of_achievement.eql? type_of_achievement.to_s }).any?
  false
end
