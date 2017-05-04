# frozen_string_literal: true

class Evaluation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  after_save :update_course_rating_and_count, if: :rating_changed?
  after_destroy :update_course_rating_and_count
  enum course_status: %i[aborted enrolled finished]

  def update_course_rating_and_count
    Course.update_course_rating_attributes course_id
  end

  def self.collect_evaluation_objects_for_course(course)
    if course.evaluations.present?
      previous_course = nil
      course_evaluations = course.evaluations
    elsif course.previous_iteration_id.present?
      course_evaluations, previous_course = Evaluation.collect_evaluations_from_a_previous_course_iteration(course)
    else
      previous_course = nil
      course_evaluations = nil
    end

    if course_evaluations.present?
      evaluations = []
      course_evaluations.each do |evaluation|
        evaluation_object = Evaluation.evaluation_to_hash(evaluation)
        evaluations << evaluation_object
      end
    else
      evaluations = nil
    end
    [evaluations, previous_course]
  end

  def self.evaluation_to_hash(evaluation)
    evaluation_object = {
      evaluation_id: evaluation.id,
      rating: evaluation.rating,
      description: evaluation.description,
      creation_date: evaluation.created_at,
      total_feedback_count: evaluation.total_feedback_count,
      positive_feedback_count: evaluation.positive_feedback_count
    }
    case evaluation.course_status.to_sym
      when :aborted
        evaluation_object[:course_status] = I18n.t('evaluations.aborted_course')
      when :enrolled
        evaluation_object[:course_status] = I18n.t('evaluations.currently_enrolled_course')
      when :finished
        evaluation_object[:course_status] = I18n.t('evaluations.finished_course')
    end
    if evaluation.rated_anonymously
      evaluation_object[:user_id] = nil
      evaluation_object[:user_name] = I18n.t('evaluations.anonymous')
    else
      evaluation_object[:user_id] = evaluation.user_id
      evaluation_object[:user_name] = "#{evaluation.user.first_name} #{evaluation.user.last_name}"
    end
    evaluation_object
  end

  def self.collect_evaluations_from_a_previous_course_iteration(course)
    previous_course_iteration = Course.find(course.previous_iteration_id)
    while previous_course_iteration.present?
      if previous_course_iteration.evaluations.present?
        course_evaluations = previous_course_iteration.evaluations
        previous_course = previous_course_iteration
        break
      end
      previous_course_iteration = if previous_course_iteration.previous_iteration_id.present?
                                    Course.find(previous_course_iteration.previous_iteration_id)
                                  end
    end
    [course_evaluations, previous_course]
  end

  def self.save_or_update_evaluation(user_id, course_id, rating, description, course_status, rated_anonymously)
    evaluation = Evaluation.find_or_initialize_by(user_id: user_id, course_id: course_id)
    evaluation.rating = rating
    evaluation.description = description
    evaluation.course_status = course_status
    evaluation.rated_anonymously = rated_anonymously
    evaluation.save
  end
end
