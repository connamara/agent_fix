require 'thread'
require 'agent_fix/message_cache'

module AgentFIX
  class Agent
    include quickfix.Application

    attr_reader :name, :connection_type
    attr_accessor :default, :session

    def initialize name, connection_type
      @name = name
      @connection_type = connection_type
      @logged_on = false
      @all_messages = MessageCache.new
      @app_messages = MessageCache.new
      @sent_messages = MessageCache.new

      @logger = Java::org.slf4j.LoggerFactory.getLogger("AgentFIX.Agent")
    end

    def onCreate(sessionId)
      @default_session = sessionId
    end

    def onLogon(sessionId)
      @logger.debug "#{@name} onLogon: #{sessionId.to_s}"

      lock.synchronize do
        @logged_on = true
      end
    end

    def onLogout(sessionId)
      @logger.debug "#{@name} onLogout: #{sessionId.to_s}"

      lock.synchronize do
        @logged_on = false
      end
    end

    def toApp(message, sessionId) 
      @logger.debug "#{@name} toApp #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
      @sent_messages.add_msg(message)
    end

    def fromApp(message, sessionId)
      @logger.debug "#{@name} fromApp #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
      
      @all_messages.add_msg(message)
      @app_messages.add_msg(message)
    end

    def toAdmin(message, sessionId)
      @logger.debug "#{@name} toAdmin #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
      @sent_messages.add_msg(message)
    end

    def fromAdmin(message, sessionId)
      @logger.debug "#{@name} fromAdmin #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
      @all_messages.add_msg(message)
    end

    def loggedOn?
      lock.synchronize do
        return @logged_on
      end
    end

    def sendToTarget msg
      msg.getHeader.setField(quickfix.field.BeginString.new(@default_session.getBeginString))
      msg.getHeader.setField(quickfix.field.TargetCompID.new(@default_session.getTargetCompID))
      msg.getHeader.setField(quickfix.field.SenderCompID.new(@default_session.getSenderCompID))

      quickfix.Session.sendToTarget(msg)
    end

    def reset
      clear!
    end

    def start
      parse_settings
      @connector = case @connection_type
        when :acceptor then quickfix.SocketAcceptor.new(self, @storeFactory, @settings, @logFactory, @messageFactory)
        when :initiator then quickfix.SocketInitiator.new(self, @storeFactory, @settings, @logFactory, @messageFactory)
        else nil
      end

      @connector.start
    end

    def stop
      @connector.stop
    end

    def messages_received opts={}
      opts[:from_all]||=false
      
      if opts[:from_all]
        @all_messages.messages_received
      else
        @app_messages.messages_received
      end
    end

    def messages_sent
      @sent_messages.messages_received
    end

    protected

    def clear!
      @all_messages.clear!
      @app_messages.clear!
    end

    def parse_settings
      session_settings = "[DEFAULT]\n"
      session_settings << "ConnectionType=#{@connection_type}\n"

      @default ||= {}
      AgentFIX::session_defaults.merge(@default).each do |k,v|
        session_settings << "#{k}=#{v}\n"
      end
    
      unless @session.nil?
        session_settings << "[SESSION]\n"
        @session.each { |k,v| session_settings << "#{k}=#{v}\n"}
      end

      @logger.info "Settings for #{@name}: #{session_settings}"

      @storeFactory = quickfix.MemoryStoreFactory.new()
      @messageFactory = quickfix.DefaultMessageFactory.new()
      @settings = quickfix.SessionSettings.new( Java::java.io.ByteArrayInputStream.new(session_settings.to_java_bytes) )
      @logFactory = quickfix.FileLogFactory.new(@settings)
    end

    private

    def lock
      @lock||=Mutex.new
    end
  end
end
