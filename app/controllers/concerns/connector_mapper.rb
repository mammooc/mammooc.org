module ConnectorMapper extend ActiveSupport::Concern

  def get_connector_by_mooc_provider mooc_provider
    case mooc_provider.name
      when 'openHPI'
        return OpenHPIConnector.new
      when 'openSAP'
        return OpenSAPConnector.new
      when 'openHPI China'
        return OpenHPIChinaConnector.new
      when 'openSAP China'
        return OpenSAPChinaConnector.new
      when 'mooc.house'
        return MoocHouseConnector.new
      when 'openUNE'
        return OpenUNEConnector.new
      else
        return nil
    end
  end

  def get_worker_by_mooc_provider mooc_provider
    case mooc_provider.name
      when 'openHPI'
        return OpenHPIUserWorker
      when 'openSAP'
        return OpenSAPUserWorker
      when 'openHPI China'
        return OpenHPIChinaUserWorker
      when 'openSAP China'
        return OpenSAPChinaUserWorker
      when 'mooc.house'
        return MoocHouseUserWorker
      when 'openUNE'
        return OpenUNEUserWorker
      else
        return nil
    end
  end

end
