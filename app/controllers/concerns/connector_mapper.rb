# frozen_string_literal: true

module ConnectorMapper
  extend ActiveSupport::Concern

  def get_connector_by_mooc_provider(mooc_provider)
    case mooc_provider.name
      when 'openHPI'
        OpenHPIConnector.new
      when 'openSAP'
        OpenSAPConnector.new
      when 'openHPI.cn'
        OpenHPIChinaConnector.new
      when 'openSAP.cn'
        OpenSAPChinaConnector.new
      when 'mooc.house'
        MoocHouseConnector.new
      when 'cnMOOC.house'
        CnmoocHouseConnector.new
      when 'openUNE.cn'
        OpenUNEConnector.new
      when 'coursera'
        CourseraConnector.new
    end
  end

  def get_worker_by_mooc_provider(mooc_provider)
    case mooc_provider.name
      when 'openHPI'
        OpenHPIUserWorker
      when 'openSAP'
        OpenSAPUserWorker
      when 'openHPI.cn'
        OpenHPIChinaUserWorker
      when 'openSAP.cn'
        OpenSAPChinaUserWorker
      when 'mooc.house'
        MoocHouseUserWorker
      when 'cnMOOC.house'
        CnmoocHouseUserWorker
      when 'openUNE.cn'
        OpenUNEUserWorker
      when 'coursera'
        CourseraUserWorker
    end
  end
end
