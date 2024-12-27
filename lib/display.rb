# lib/display.rb

require 'date'

module Display
  module_function

  def tool_has_data?(tool_name, lifecycle_data, npm_data, github_data)
    return true if lifecycle_data&.dig(tool_name)&.any?
    return true if npm_data&.dig(tool_name)
    return true if github_data&.dig(tool_name)
    false
  end

  def category_has_data?(tools, lifecycle_data, npm_data, github_data)
    tools.any? do |tool_name, _|
      tool_has_data?(tool_name, lifecycle_data, npm_data, github_data)
    end
  end

  def text_output(tech_stack, lifecycle_data, npm_data, github_data, warnings, upcoming_releases)
    puts "\n=== Current Version Status ==="
    
    tech_stack.each do |category, tools|
      next unless category_has_data?(tools, lifecycle_data, npm_data, github_data)
      
      puts "\n#{category.upcase}"
      puts "=" * category.length
      
      tools.each do |tool_name, config|
        next unless tool_has_data?(tool_name, lifecycle_data, npm_data, github_data)
        
        puts "\n#{tool_name.upcase}"
        puts "-" * tool_name.length
        
        if lifecycle_data[tool_name]
          show_lifecycle_info(tool_name, lifecycle_data[tool_name])
        end

        if npm_data[tool_name]
          show_npm_info(npm_data[tool_name])
        end

        show_support_policy(tool_name)
      end
    end

    show_eol_warnings(warnings)
    show_upcoming_releases(upcoming_releases)
  end

  def generate_html(tech_stack, lifecycle_data, npm_data, github_data, warnings, upcoming_releases)
    content = []
    
    tech_stack.each do |category, tools|
      next unless category_has_data?(tools, lifecycle_data, npm_data, github_data)
      
      content << "<div class='category'>"
      content << "<h2>#{category.upcase}</h2>"
      
      tools.each do |tool_name, config|
        next unless tool_has_data?(tool_name, lifecycle_data, npm_data, github_data)
        
        content << "<h3>#{tool_name.upcase}</h3>"
        
        if lifecycle_data[tool_name]
          content << format_lifecycle_html(tool_name, lifecycle_data[tool_name])
        end

        if npm_data[tool_name]
          content << format_npm_html(npm_data[tool_name])
        end

        if policy = TechStackConfig.support_policies[tool_name]
          content << "<p class='support-policy'>#{policy}</p>"
        end
      end
      
      content << "</div>"
    end

    content << format_warnings_html(warnings) if warnings.any?
    content << format_releases_html(upcoming_releases) if upcoming_releases.any?
    
    content.join("\n")
  end

  def format_lifecycle_html(tool_name, versions)
    return "" unless versions.is_a?(Array) && !versions.empty?
    
    current_versions = versions.sort_by { |v| v['releaseDate'] || '0000-00-00' }.reverse
    latest_lts = current_versions.find { |v| v['lts'] == true }
    latest_stable = current_versions.first
    
    html = []
    html << "<div class='tool'>"
    
    html << "<div class='version-info'>"
    html << "<h4>Latest Stable Version</h4>"
    html << HTMLFormatter.format_version_info(latest_stable, false)
    
    if latest_lts && latest_lts != latest_stable
      html << "<h4>Latest LTS Version</h4>"
      html << HTMLFormatter.format_version_info(latest_lts, true)
    end
    html << "</div>"
    
    html << "</div>"
    html.join("\n")
  end

  def format_npm_html(data)
    <<~HTML
      <div class="tool npm-info">
        <p class="version">Latest Version: #{data['latest_version']}</p>
        <p>Release Date: #{data['time'][data['latest_version']]}</p>
      </div>
    HTML
  end

  def format_warnings_html(warnings)
    return "" if warnings.empty?
    
    html = ["<div class='warnings'>"]
    html << "<h2>EOL Warnings (Next 90 Days)</h2>"
    
    warnings.sort_by { |w| w[:days_remaining] }.each do |warning|
      html << <<~HTML
        <div class="warning">
          #{warning[:tool]} #{warning[:version]}: EOL in #{warning[:days_remaining]} days (#{warning[:eol_date]})
        </div>
      HTML
    end
    
    html << "</div>"
    html.join("\n")
  end

  def format_releases_html(releases)
    return "" if releases.empty?
    
    html = ["<div class='releases'>"]
    html << "<h2>Upcoming Releases (Next 90 Days)</h2>"
    
    releases.sort_by { |r| r[:days_until] }.each do |release|
      html << <<~HTML
        <div class="release">
          #{release[:tool]} #{release[:version]}: Releasing in #{release[:days_until]} days (#{release[:release_date]})
        </div>
      HTML
    end
    
    html << "</div>"
    html.join("\n")
  end

  def show_lifecycle_info(tool_name, versions)
    return unless versions.is_a?(Array) && !versions.empty?
    current_versions = versions.sort_by { |v| v['releaseDate'] || '0000-00-00' }.reverse
    latest_lts = current_versions.find { |v| v['lts'] == true }
    latest_stable = current_versions.first

    puts "\nLatest Stable Version:"
    version_info(latest_stable, is_lts: false)
    
    if latest_lts && latest_lts != latest_stable
      puts "\nLatest LTS Version:"
      version_info(latest_lts, is_lts: true)
    end
  end

  def show_npm_info(data)
    puts "  Latest Version: #{data['latest_version']}"
    puts "  Release Date: #{data['time'][data['latest_version']]}"
  end

  def show_support_policy(tool_name)
    if policy = TechStackConfig.support_policies[tool_name]
      puts "\nSupport Policy:"
      puts "  #{policy}"
    end
  end

  def show_eol_warnings(warnings)
    puts "\n=== EOL Warnings (Next 90 Days) ==="
    if warnings.empty?
      puts "No immediate EOL warnings."
    else
      warnings.sort_by { |w| w[:days_remaining] }.each do |warning|
        puts "#{warning[:tool]} #{warning[:version]}: EOL in #{warning[:days_remaining]} days (#{warning[:eol_date]})"
      end
    end
  end

  def show_upcoming_releases(releases)
    puts "\n=== Upcoming Releases (Next 90 Days) ==="
    if releases.empty?
      puts "No upcoming releases found."
    else
      releases.sort_by { |r| r[:days_until] }.each do |release|
        puts "#{release[:tool]} #{release[:version]}: Releasing in #{release[:days_until]} days (#{release[:release_date]})"
      end
    end
  end

  def version_info(version, is_lts: false)
    puts "  Version: #{version['cycle']} (Released: #{version['releaseDate']})"
    puts "  LTS: #{is_lts ? 'Yes' : 'No'}"
    
    support_status = version['support']
    if support_status.nil? || support_status == 'Unknown'
      puts "  Support Status: Check vendor website"
    elsif support_status == true
      puts "  Support Status: Active"
    else
      puts "  Support Status: Until #{support_status}"
    end
    
    eol = version['eol']
    if eol.nil? || eol == 'Unknown'
      puts "  End of Life: Check vendor website"
    elsif eol == true
      puts "  End of Life: Supported"
    elsif eol == false
      puts "  End of Life: Ended"
    else
      puts "  End of Life: #{eol}"
    end
  end
end