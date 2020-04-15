# frozen_string_literal: true

module ConnectorMapper
  extend ActiveSupport::Concern

  def get_connector_by_mooc_provider(mooc_provider)
    case mooc_provider.name
      when 'openHPI'
        OpenHPIConnector.new
      when 'openSAP'
        OpenSAPConnector.new
      when 'mooc.house'
        MoocHouseConnector.new
      when 'OpenWHO'
        OpenWHOConnector.new
      when 'Lernen.cloud'
        LernenCloudConnector.new
      when 'coursera'
        # CourseraConnector.new
        nil
    end
  end

  def get_worker_by_mooc_provider(mooc_provider)
    case mooc_provider.name
      when 'openHPI'
        OpenHPIUserWorker
      when 'openSAP'
        OpenSAPUserWorker
      when 'Lernen.cloud'
        LernenCloudUserWorker
      when 'mooc.house'
        MoocHouseUserWorker
      when 'OpenWHO'
        OpenWHOUserWorker
      when 'coursera'
        # CourseraUserWorker
        nil
    end
  end
end
