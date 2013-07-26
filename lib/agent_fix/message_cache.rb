require 'thread'
module AgentFIX
  module MessageCache
    def messages_received
      lock.synchronize do
        return messages.dup
      end
    end
    
    def admin_messages_received
      admin_lock.synchronize do
        return admin_messages.dup
      end
    end
      
    def app_messages_received
      app_lock.synchronize do
        return app_messages.dup
      end
    end
    
    def pop
      lock.synchronize do
        return messages.pop
      end
    end
    
    def pop_admin
      admin_lock.synchronize do
        return admin_messages.pop
      end
    end
    
    def pop_app
      app_lock.synchronize do
        return app_messages.pop
      end
    end

    def add_msg msg
      lock.synchronize do
        messages << msg
      end
    end
    
    def add_admin_msg msg
      admin_lock.synchronize do
        admin_messages << msg
      end
    end
    
    def add_app_msg msg
      app_lock.synchronize do
        app_messages << msg
      end
    end

    def clear
      lock.synchronize do
        messages.clear
      end
    end
    
    def clear_admin
      admin_lock.synchronize do
        admin_messages.clear
      end
    end
    
    def clear_app
      app_lock.synchronize do
        app_messages.clear
      end
    end

  private
    def messages
      @messages||=[]
    end
    
    def admin_messages
      @admin_messages||=[]
    end
    
    def app_messages
      @app_messages||=[]
    end

    def lock
      @lock||=Mutex.new
    end
    
    def admin_lock
      @admin_lock||=Mutex.new
    end
    
    def app_lock
      @app_lock||=Mutex.new
    end
  end
end
