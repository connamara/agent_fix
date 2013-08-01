module AgentFIX
  module Configuration
    REASONABLE_SESSION_DEFAULTS = {
      StartTime: "00:00:00",
      EndTime: "00:00:00",
      FileLogPath: "fixlog",
      HeartBtInt: 60
    }
    
    def message_scope_level=(scope)
      @message_scope_level = scope
    end
    
    def message_scope_level
      @message_scope_level ||= {:from_all => false}
    end

    def cucumber_sleep_seconds=(secs)
      @cucumber_sleep_seconds = secs
    end

    def cucumber_sleep_seconds
      @cucumber_sleep_seconds ||= 0.5
    end

    def cucumber_retries=(retries)
      @cucumber_retries = retries
    end

    def cucumber_retries
      @cucumber_retries ||= 10
    end

    def session_defaults=(defaults)
      @session_defaults = defaults
    end

    def session_defaults
      @session_defaults ||= REASONABLE_SESSION_DEFAULTS
    end
  end
end
