require 'http'
require 'json'
require 'dotenv/load'
require 'time'

# Use Ruby's built-in Time class instead of Rails' Time.zone
# Set timezone to UTC for consistency
ENV['TZ'] = 'UTC'

# Load environment variables from GitHub Secrets
RECIPIENT_EMAIL = ENV['RECIPIENT_EMAIL']
SENDER_EMAIL    = ENV['SENDER_EMAIL']
RESEND_API_KEY  = ENV['RESEND_API_KEY']
DRY_RUN         = ENV['DRY_RUN'] == 'true'

# Base URLs
BASE_URL        = 'https://endoflife.date/api/'
RESEND_API_URL  = 'https://api.resend.com/emails'

TRACKED_TECHS = %w[
  amazon-rds-postgresql macos bun go grafana terraform memcached nginx nodejs
  nvm openssl postgresql python redis ruby rails sqlite ubuntu
]

# Parse date strings safely
def parse_date(date_str)
  return nil unless date_str.is_a?(String) && date_str =~ /\d{4}-\d{2}-\d{2}/
  Time.parse(date_str)
rescue ArgumentError
  nil
end

# Fetch data for a single product
def fetch_product_data(product)
  response = HTTP.get("#{BASE_URL}#{product}.json")
  return JSON.parse(response.body) if response.status.success?
  nil
rescue StandardError => e
  puts "Error fetching data for #{product}: #{e.message}"
  nil
end

# Filter versions (EOL > 2 years ago or invalid data)
def filter_versions(versions)
  cutoff_time = Time.now - (2 * 365 * 24 * 60 * 60) # ~2 years ago
  versions.select do |version|
    eol = version['eol']
    case eol
    when false
      true # Active indefinitely
    when true, nil, 'Unknown'
      false # Invalid or expired
    else
      parsed_eol = parse_date(eol)
      parsed_eol && parsed_eol > cutoff_time
    end
  end
end

# Categorize and sort versions
def categorize_and_sort_versions(versions)
  now = Time.now
  cutoff_time = now - (2 * 365 * 24 * 60 * 60) # 2 years ago
  six_months_from_now = now + (6 * 30 * 24 * 60 * 60) # ~6 months

  active_versions = []
  recently_eol_versions = []

  versions.each do |version|
    eol = version['eol']
    parsed_eol = parse_date(eol)
    if eol == false || (parsed_eol && parsed_eol > now)
      active_versions << version.merge('approaching_eol' => (parsed_eol && parsed_eol <= six_months_from_now))
    elsif parsed_eol && parsed_eol > cutoff_time
      recently_eol_versions << version
    end
  end

  # Sort active versions by EOL date (earliest first, indefinite last)
  active_versions.sort_by! do |v|
    eol = parse_date(v['eol'])
    [eol ? 0 : 1, eol || Time.at(0)]
  end

  # Sort recently EOL versions by EOL date (most recent first)
  recently_eol_versions.sort_by! { |v| parse_date(v['eol']) || Time.at(0) }.reverse!

  { active: active_versions, recently_eol: recently_eol_versions }
end

# Generate a detailed HTML report
def generate_html_report
  html_report = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>End-of-Life Report</title>
      <style>
        body { font-family: Arial, sans-serif; }
        h1 { text-align: center; margin-top: 30px; }
        h2 { text-align: center; }
        table { border-collapse: collapse; width: 90%; margin: 20px auto; }
        th, td { border: 1px solid #dddddd; text-align: left; padding: 8px; }
        th { background-color: #f2f2f2; }
        .product-header { background-color: #cce5ff; text-transform: capitalize; }
        .approaching-eol { background-color: #ffcccc; }
      </style>
    </head>
    <body>
      <h1>End-of-Life Report - #{Time.now.strftime('%Y-%m-%d')}</h1>
  HTML

  TRACKED_TECHS.each do |product|
    product_data = fetch_product_data(product)
    unless product_data
      html_report << "<h2>#{product.capitalize}</h2>\n<p>Error fetching data.</p>\n"
      next
    end

    filtered_data = filter_versions(product_data)
    if filtered_data.empty?
      html_report << "<h2>#{product.capitalize}</h2>\n<p>No relevant versions found.</p>\n"
      next
    end

    categorized = categorize_and_sort_versions(filtered_data)
    html_report << "<h2>#{product.capitalize}</h2>\n"

    # Currently Supported Versions
    unless categorized[:active].empty?
      html_report << "<h3>Currently Supported Versions</h3>\n<table>\n"
      html_report << "  <tr><th>Version</th><th>Status</th><th>LTS</th></tr>\n"
      categorized[:active].each do |release|
        eol = release['eol']
        status = eol == false ? 'Active (Indefinite)' : "Supported until #{eol}"
        status += ' (Approaching EOL)' if release['approaching_eol']
        lts = release['lts'] ? 'LTS' : 'Non-LTS'
        row_class = release['approaching_eol'] ? ' class="approaching-eol"' : ''
        html_report << "  <tr#{row_class}><td>#{release['cycle']}</td><td>#{status}</td><td>#{lts}</td></tr>\n"
      end
      html_report << "</table>\n"
    end

    # Recently EOL Versions
    unless categorized[:recently_eol].empty?
      html_report << "<h3>Recently EOL Versions</h3>\n<table>\n"
      html_report << "  <tr><th>Version</th><th>Status</th><th>LTS</th></tr>\n"
      categorized[:recently_eol].each do |release|
        eol = release['eol']
        lts = release['lts'] ? 'LTS' : 'Non-LTS'
        html_report << "  <tr><td>#{release['cycle']}</td><td>EOL since #{eol}</td><td>#{lts}</td></tr>\n"
      end
      html_report << "</table>\n"
    end
  end

  html_report << "</body></html>\n"
  html_report
end

# Send the report via Resend API
def send_email(html_report)
  payload = {
    from: SENDER_EMAIL,
    to: RECIPIENT_EMAIL,
    subject: "Monthly End-of-Life Report - #{Time.now.strftime('%Y-%m-%d')}",
    html: html_report
  }

  response = HTTP.auth("Bearer #{RESEND_API_KEY}").post(RESEND_API_URL, json: payload)
  if response.status.success?
    puts "Email sent successfully!"
  else
    puts "Error sending email: #{response.status} - #{response.body}"
  end
rescue StandardError => e
  puts "Email sending failed: #{e.message}"
end

# Main function
def main
  report = generate_html_report
  if DRY_RUN
    puts "DRY_RUN is set. Here is the HTML output:\n\n#{report}\n\nNo email was sent."
  else
    send_email(report)
  end
end

main