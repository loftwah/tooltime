require 'http'
require 'json'
require 'dotenv/load'
require 'time'

# Load environment variables
RECIPIENT_EMAIL = ENV['RECIPIENT_EMAIL']
SENDER_EMAIL    = ENV['SENDER_EMAIL']
RESEND_API_KEY  = ENV['RESEND_API_KEY']
DRY_RUN         = ENV['DRY_RUN'] == 'true'

# Base URL for product-specific API queries
BASE_URL        = 'https://endoflife.date/api/'
RESEND_API_URL  = 'https://api.resend.com/emails'

TRACKED_TECHS = %w[
  amazon-rds-postgresql macos bun go grafana terraform memcached nginx nodejs
  nvm openssl postgresql python redis ruby rails sqlite ubuntu
]

# Fetch data for a single product
def fetch_product_data(product)
  response = HTTP.get("#{BASE_URL}#{product}.json")
  return JSON.parse(response.body) if response.status.success?
  nil
rescue StandardError => e
  puts "Error fetching data for #{product}: #{e.message}"
  nil
end

# Filter out irrelevant versions (EOL > 2 years ago or invalid data)
def filter_versions(versions)
  cutoff_date = (Time.now - (2 * 365 * 24 * 60 * 60)).strftime('%Y-%m-%d') # ~2 years ago
  versions.select do |version|
    eol_date = version['eol']

    case eol_date
    when false
      # Active versions
      true
    when true
      # Invalid EOL, treat as expired
      false
    when nil, 'Unknown'
      # Exclude invalid or unknown EOL dates
      false
    else
      # Compare only when eol_date is a valid date string
      eol_date > cutoff_date
    end
  end
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
        body {
          font-family: Arial, sans-serif;
        }
        h1 {
          text-align: center;
          margin-top: 30px;
        }
        table {
          border-collapse: collapse;
          width: 90%;
          margin: 20px auto;
        }
        th, td {
          border: 1px solid #dddddd;
          text-align: left;
          padding: 8px;
        }
        th {
          background-color: #f2f2f2;
        }
        .product-header {
          background-color: #cce5ff;
          text-transform: capitalize;
        }
      </style>
    </head>
    <body>
      <h1>End-of-Life Report - #{Time.now.strftime('%Y-%m-%d')}</h1>
  HTML

  TRACKED_TECHS.each do |product|
    product_data = fetch_product_data(product)
    next unless product_data

    filtered_data = filter_versions(product_data)
    next if filtered_data.empty?

    html_report << "<h2 style=\"text-align:center;\">#{product.capitalize}</h2>\n"
    html_report << "<table>\n"
    html_report << "  <tr>\n"
    html_report << "    <th>Version</th>\n"
    html_report << "    <th>Status</th>\n"
    html_report << "    <th>LTS</th>\n"
    html_report << "  </tr>\n"

    filtered_data.each do |release|
      eol    = release['eol'] || 'Unknown'
      lts    = release['lts'] ? 'LTS' : 'Non-LTS'
      status = eol == false ? 'Active' : "EOL by #{eol}"

      html_report << "  <tr>\n"
      html_report << "    <td>#{release['cycle']}</td>\n"
      html_report << "    <td>#{status}</td>\n"
      html_report << "    <td>#{lts}</td>\n"
      html_report << "  </tr>\n"
    end

    html_report << "</table>\n"
  end

  html_report << <<~HTML
    </body>
    </html>
  HTML
  html_report
end

# Send the report via Resend API
def send_email(html_report)
  payload = {
    from: SENDER_EMAIL,
    to: RECIPIENT_EMAIL,
    subject: 'Monthly End-of-Life Report',
    html: html_report
  }

  response = HTTP
    .auth("Bearer #{RESEND_API_KEY}")
    .post(RESEND_API_URL, json: payload)

  if response.status.success?
    puts "Email sent successfully!"
  else
    puts "Error sending email: #{response.status} - #{response.body}"
  end
end

# Main function
def main
  report = generate_html_report

  if DRY_RUN
    puts "DRY_RUN is set. Here is the HTML output:\n\n"
    puts report
    puts "\nNo email was sent."
  else
    send_email(report)
  end
end

main
