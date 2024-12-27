# send_update.rb
require 'net/http'
require 'json'
require 'date'

# Load environment variables if not in GitHub Actions
if !ENV['GITHUB_ACTIONS']
  require 'dotenv'
  Dotenv.load
end

def send_email(api_key, from_email, to_email, subject, html_content)
  uri = URI('https://api.resend.com/emails')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri)
  request['Authorization'] = "Bearer #{api_key}"
  request['Content-Type'] = 'application/json'

  request.body = {
    from: from_email,
    to: to_email,
    subject: subject,
    html: html_content
  }.to_json

  response = http.request(request)
  
  if response.is_a?(Net::HTTPSuccess)
    puts "Email sent successfully!"
    JSON.parse(response.body)
  else
    puts "Failed to send email: #{response.code} - #{response.body}"
    exit 1
  end
end

email_content = File.read('tech_update.html')
current_date = Date.today.strftime('%B %Y')

begin
  response = send_email(
    ENV['RESEND_API_KEY'],
    'Tech Stack Updates <dean@deanlofts.xyz>',
    ENV['RECIPIENT_EMAIL'],
    "Tech Stack Update - #{current_date}",
    email_content
  )
  puts "Email ID: #{response['id']}" if response['id']
rescue => e
  puts "Error sending email: #{e.message}"
  exit 1
end