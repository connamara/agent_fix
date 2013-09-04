class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
  
  def white
    colorize(37)
  end
  
  def blue
    colorize(34)
  end
  
  def magenta
    colorize(35)
  end
  
  def cyan
    colorize(36)
  end
end

def print_results agent
  STDERR.puts "\nMessages for ".yellow + agent.name.to_s.white + ": ".yellow
  
  agent.history(:include_session=>true).each do |msg|
    if msg[:sent]
      STDERR.puts "\tsent >>\t #{msg[:message].to_s.gsub!(/\001/, '|')}".green
    else
      outbound = "\trecv <<\t #{msg[:message].to_s.gsub!(/\001/, '|')}"

      if @message!=nil and msg[:message] == @message
        STDERR.puts outbound.red
      else
        if msg[:index] >= @agent.bookmark
          STDERR.puts outbound.blue
        else

          if @message_scope.include? msg[:message]
            STDERR.puts outbound.pink
          else
            STDERR.puts outbound.green
          end
        end
      end
    end
  end
end

After do |scenario|
  if scenario.failed? then
    #last selected agent gets priority
    unless @agent.nil?
      print_results(@agent)
    end

    AgentFIX.agents_hash.values.each do |agent|
      next if agent == @agent
      print_results(agent)
    end
  end
end
