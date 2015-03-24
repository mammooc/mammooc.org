class AbstractCourseWorker
  include Sidekiq::Worker
  require 'rest_client'

  def perform
    loadCourses
  end

  def loadCourses
    responseData = getCourseData
    handleResponseData responseData
  end

  def moocProvider
    raise NotImplementedError
  end

  def getCourseData
    raise NotImplementedError
  end

  def handleResponseData responseData
    raise NotImplementedError
  end

  def createUpdateMap
    updateMap = Hash.new
    Course.where(:mooc_provider_id => moocProvider.id).each { |course|
      updateMap.store(course.id, false)
    }
    return updateMap
  end

  def evaluateUpdateMap updateMap
    updateMap.each { |course_id,updated|
      if !updated
        Course.find(course_id).destroy
      end
    }
  end

end
