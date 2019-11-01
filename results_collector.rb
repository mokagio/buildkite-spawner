require 'dotenv'
require 'json'
require './lib/config_reader.rb'
require 'optparse'
require 'rest-client'

local_config = read_local_config

Dotenv.load
buildkite_api_token = ENV['BK_API_TOKEN']
raise 'Missing Buildkite API token as BK_API_TOKEN' if buildkite_api_token.nil?

input_config = {}
OptionParser.new do |opts|
  add_commit_option(opts)
  add_number_option(opts)
  add_organization_option(opts)
  add_pipeline_option(opts)
end.parse!(into: input_config)

# input configs override local ones
config = local_config.merge(input_config)

raise 'Missing commit full SHA' if config[:commit].nil?
raise 'Missing pipeline' if config[:pipeline].nil?
raise 'Missing number of builds to check (this will become computed soon)' if config[:number].nil?
raise 'Missing organization' if config[:organization].nil?

base_url = "https://api.buildkite.com/v2/organizations/#{config[:organization]}"

# The API response is paginated, but without next page information (that I
# could find). This means we can't just get _all_ the builds for a given commit
# if we run more that 100. So, let's just get those that failed.
# See https://buildkite.com/docs/apis/rest-api/builds#list-builds-for-a-pipeline
url = "#{base_url}/pipelines/#{config[:pipeline]}/builds?commit=#{config[:commit]}&state=failed"
json = JSON.parse(RestClient.get(url, headers = { 'Authorization' => "Bearer #{buildkite_api_token}" }).body)

failed = json.map { |build| build['web_url'] }

success_rate = (100 - (failed.length.to_f / config[:number] * 100)).round(2)

puts "#{failed.length} out of #{config[:number]} failed for commit #{config[:commit]} (#{success_rate}% success rate)"

unless failed.empty?
  puts "\nFailed builds:"
  failed.reverse.each do |build_url|
    puts "- #{build_url}"
  end
end
