# tooltime.rb

require 'date'
require 'optparse'
require_relative 'config/tech_stack'
require_relative 'lib/data_fetcher'
require_relative 'lib/display'
require_relative 'lib/html_formatter'

class LifecycleTracker
  def initialize(options = {})
    @tech_stack = TechStackConfig.load_tech_stack
    @lifecycle_data = {}
    @github_data = {}
    @npm_data = {}
    @github_token = ENV['GITHUB_TOKEN']
    @format = options[:format] || 'text'
    @output_file = options[:output] || (@format == 'html' ? 'tech_update.html' : nil)
  end

  def fetch_all_lifecycle_data
    @tech_stack.each do |category, tools|
      tools.each do |tool_name, config|
        puts "Fetching lifecycle data for #{tool_name}..."
        
        if config[:source] == 'endoflife'
          data = DataFetcher.fetch_from_endoflife(tool_name)
          @lifecycle_data[tool_name] = data if data
        end

        if config[:github]
          data = DataFetcher.fetch_github_data(tool_name, config[:github], @github_token)
          @github_data[tool_name] = data if data
          
          if config[:release_pattern] == 'github'
            releases = DataFetcher.fetch_github_releases(config[:github], @github_token)
            @lifecycle_data[tool_name] = DataFetcher.format_github_releases(releases) if releases
          end
        end

        if config[:npm_package]
          data = DataFetcher.fetch_npm_data(config[:npm_package])
          @npm_data[tool_name] = data if data
        end
      end
    end
    
    @trending_data = DataFetcher.fetch_github_trending(@github_token)
  end

  def analyze_lifecycle_status
    warnings = []
    upcoming_releases = []
    current_date = Date.today

    @lifecycle_data.each do |tool_name, versions|
      next unless versions.is_a?(Array)

      versions.each do |version|
        next unless version['cycle'] && version['eol']

        eol_date = version['eol'].is_a?(String) ? Date.parse(version['eol']) : nil
        
        if eol_date
          days_until_eol = (eol_date - current_date).to_i
          
          if days_until_eol.between?(0, 90)
            warnings << {
              tool: tool_name,
              version: version['cycle'],
              eol_date: eol_date,
              days_remaining: days_until_eol
            }
          end
        end

        if version['releaseDate']
          release_date = Date.parse(version['releaseDate'])
          days_until_release = (release_date - current_date).to_i
          
          if days_until_release.between?(0, 90) && days_until_release > 0
            upcoming_releases << {
              tool: tool_name,
              version: version['cycle'],
              release_date: release_date,
              days_until: days_until_release
            }
          end
        end
      end
    end

    output_results(warnings, upcoming_releases)
  end

  def output_results(warnings, upcoming_releases)
    if @format == 'html'
      content = Display.generate_html(@tech_stack, @lifecycle_data, @npm_data, @github_data, 
                                    @trending_data, warnings, upcoming_releases)
      html = HTMLFormatter.wrap_content(content)
      
      if @output_file
        File.write(@output_file, html)
        puts "HTML report generated: #{@output_file}"
      else
        puts html
      end
    else
      Display.text_output(@tech_stack, @lifecycle_data, @npm_data, @github_data,
                         @trending_data, warnings, upcoming_releases)
    end
  end
end

if __FILE__ == $0
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: tooltime.rb [options]"

    opts.on("--format FORMAT", "Output format (text/html)") do |format|
      options[:format] = format
    end

    opts.on("--output FILE", "Output file") do |file|
      options[:output] = file
    end
  end.parse!

  tracker = LifecycleTracker.new(options)
  tracker.fetch_all_lifecycle_data
  tracker.analyze_lifecycle_status
end