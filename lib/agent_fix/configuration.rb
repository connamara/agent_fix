module AgentFIX
  module Configuration
    REASONABLE_SESSION_DEFAULTS = {
      StartTime: "00:00:00",
      EndTime: "00:00:00",
      FileLogPath: "fixlog",
      HeartBtInt: 60
    }

    def session_defaults=(defaults)
      @session_defaults = defaults
    end

    def session_defaults
      @session_defaults ||= REASONABLE_SESSION_DEFAULTS
    end
  end
end
