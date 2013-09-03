require 'thread'
module AgentFIX
  class MessageCache
    def messages
      lock.synchronize do
        return msgs.dup
      end
    end
    
    def pop
      lock.synchronize do
        return msgs.pop
      end
    end
    
    def add_message msg
      lock.synchronize do
        msgs << msg
      end
    end
    
    def clear!
      lock.synchronize do
        msgs.clear
      end
    end
    
  private
    def msgs
      @messages||=[]
    end
    
    def lock
      @lock||=Mutex.new
    end
  end
end
