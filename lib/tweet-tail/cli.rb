require 'optparse'

module TweetTail::CLI
  def self.execute(stdout, arguments=[])
    options = { :polling => false, :output_format => :text }
    
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
      opts.on("-y", "--yaml", "output yaml") { |arg| options[:output_format] = :yaml }
      opts.on("-j", "--json", "output json") { |arg| options[:output_format] = :json }
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
      render(stdout, app, options[:output_format])
      while(options[:polling])
        Kernel::sleep(15)
        app.refresh
        if app.render_latest_results.size > 0
          render(stdout, app, options[:output_format])
        end
      end
    rescue Interrupt
    end
  end
  
  def self.render(stdout, poller, format)
    if format == :text
      stdout.puts poller.render_latest_results
    else
      stdout.puts poller.latest_results.send "to_#{format}".to_sym
    end
  end
  
end
