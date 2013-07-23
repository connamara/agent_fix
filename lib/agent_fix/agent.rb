require 'thread'
require 'agent_fix/message_cache'

module AgentFIX
  class Agent
    include quickfix.Application
    include MessageCache

    attr_reader :name, :connection_type
    attr_accessor :default, :session

    def initialize name, connection_type
      @name = name
      @connection_type = connection_type

      @logged_on = false
    end

    def onCreate(sessionId)
      @default_session = sessionId
    end

    def onLogon(sessionId)
      puts "#{@name} onLogon: #{sessionId.to_s}"

      lock.synchronize do
        @logged_on = true
      end
    end

    def onLogout(sessionId)
      puts "#{@name} onLogout: #{sessionId.to_s}"

      lock.synchronize do
        @logged_on = false
      end
    end

    def toApp(message, sessionId) 
      puts "#{@name} toApp #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
    end

    def fromApp(message, sessionId)
      puts "#{@name} fromApp #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
      add_msg(message)
    end

    def toAdmin(message, sessionId)
      puts "#{@name} toAdmin #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
    end

    def fromAdmin(message, sessionId)
      puts "* fromAdmin #{sessionId.to_s}: #{message.to_s.gsub("","|")}"
      add_msg(message)
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
      clear
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



    protected
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
