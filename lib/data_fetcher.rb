# lib/data_fetcher.rb

require 'net/http'
require 'json'
require 'nokogiri'

module DataFetcher
  module_function

  ENDOFLIFE_BASE_URL = 'https://endoflife.date/api'
  GITHUB_API_URL = 'https://api.github.com'
  NPM_REGISTRY_URL = 'https://registry.npmjs.org'

  def fetch_from_endoflife(tool_name)
    uri = URI("#{ENDOFLIFE_BASE_URL}/#{tool_name}.json")
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      puts "Failed to fetch data for #{tool_name}: #{response.code}"
      nil
    end
  rescue => e
    puts "Error fetching endoflife data for #{tool_name}: #{e.message}"
    nil
  end

  def fetch_github_data(tool_name, repo, token = nil)
    uri = URI("#{GITHUB_API_URL}/repos/#{repo}")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{token}" if token
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  rescue => e
    puts "Error fetching GitHub data for #{tool_name}: #{e.message}"
    nil
  end

  def fetch_github_releases(repo, token = nil)
    uri = URI("#{GITHUB_API_URL}/repos/#{repo}/releases")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "token #{token}" if token
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  rescue => e
    puts "Error fetching GitHub releases for #{repo}: #{e.message}"
    nil
  end

  def fetch_npm_data(package)
    uri = URI("#{NPM_REGISTRY_URL}/#{package}")
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      {
        'latest_version' => data['dist-tags']['latest'],
        'versions' => data['versions'].keys,
        'time' => data['time']
      }
    end
  rescue => e
    puts "Error fetching npm data for #{package}: #{e.message}"
    nil
  end

  def check_service_status(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue => e
    puts "Error checking service status at #{url}: #{e.message}"
    false
  end

  def format_github_releases(releases)
    releases.map do |release|
      {
        'cycle' => release['tag_name'],
        'releaseDate' => release['published_at']&.split('T')&.first,
        'eol' => false,
        'latest' => release['tag_name']
      }
    end
  end
end