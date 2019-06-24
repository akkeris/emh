module AutomationFramework
  # This Class instantiates all app support classes
  # rubocop:disable Metrics/ClassLength
  class Application < AutomationFramework::Utilities

    def taas
      @taas ||= Taas.new
    end
  end
  # rubocop:enable Metrics/ClassLength
end
