require 'optparse'

module TweetTail::CLI
  def self.execute(stdout, arguments=[])
    options = { :polling => false, :html => false }
    
    parser = OptionParser.new do |opts|
      opts.banner = <<-BANNER.gsub(/^          /,'')
        Display latest twitter search results. Even poll for them for hours of fun.
        
        Usage: #{File.basename($0)} [options]
        
        Options are:
      BANNER
      opts.separator ""
      opts.on("-f", "Poll for new search results each 15 seconds."
              ) { |arg| options[:polling] = true }
      opts.on("-h", "--help",
              "Show this help message.") { stdout.puts opts; exit }
      opts.on("--html", "output html") { |arg| options[:html] = true }
      opts.parse!(arguments)
    end
    
    unless query = arguments.shift
      stdout.puts parser
      exit
    end

    begin
      app = TweetTail::TweetPoller.new(query)
      app.extend(TweetTail::AnsiTweetFormatter) if stdout.tty?
      
      app.refresh
      if options[:html]
        stdout.puts app.render_latest_results(TweetTail::HtmlTweetFormatter)
      else
        stdout.puts app.render_latest_results(nil)
      end
      while(options[:polling])
        Kernel::sleep(15)
        app.refresh
        if app.render_latest_results.size > 0
          if options[:html]
            stdout.puts app.render_latest_results(TweetTail::HtmlTweetFormatter)
          else
            stdout.puts app.render_latest_results(nil)
          end
        end
      end
    rescue Interrupt
    end
  end
  
end
