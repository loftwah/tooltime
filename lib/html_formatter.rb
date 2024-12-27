# lib/html_formatter.rb

module HTMLFormatter
  class << self
    def wrap_content(content)
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Tech Stack Update</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 1200px; margin: 0 auto; padding: 20px; }
            h1, h2 { color: #2563eb; }
            .category { margin-top: 30px; }
            .tool { background: #f8fafc; padding: 15px; margin: 10px 0; border-radius: 8px; }
            .version { color: #059669; font-weight: bold; }
            .eol-warning { color: #dc2626; }
          </style>
        </head>
        <body>
          <h1>Tech Stack Update - #{Date.today.strftime('%B %Y')}</h1>
          #{content}
        </body>
        </html>
      HTML
    end

    def format_version_info(version, is_lts)
      <<~HTML
        <div class="tool">
          <p class="version">Version: #{version['cycle']} (Released: #{version['releaseDate']})</p>
          <p>LTS: #{is_lts ? 'Yes' : 'No'}</p>
          <p>Support Status: #{format_support_status(version['support'])}</p>
          <p>End of Life: #{format_eol(version['eol'])}</p>
        </div>
      HTML
    end

    def format_support_status(status)
      return 'Check vendor website' if status.nil? || status == 'Unknown'
      return 'Active' if status == true
      "Until #{status}"
    end

    def format_eol(eol)
      return 'Check vendor website' if eol.nil? || eol == 'Unknown'
      return 'Supported' if eol == true
      return 'Ended' if eol == false
      eol
    end

    def format_eol_warnings(warnings)
      return '' if warnings.empty?
      
      content = warnings.map do |warning|
        <<~HTML
          <div class="eol-warning">
            #{warning[:tool]} #{warning[:version]}: EOL in #{warning[:days_remaining]} days (#{warning[:eol_date]})
          </div>
        HTML
      end.join("\n")

      "<h2>EOL Warnings (Next 90 Days)</h2>#{content}"
    end
  end
end