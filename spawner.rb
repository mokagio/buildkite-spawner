require 'json'
require './lib/config_reader.rb'
require 'optparse'
require 'rest-client'

local_config = read_local_config

buildkite_api_token = ENV['BK_API_TOKEN']
raise 'Missing Buildkite API token as BK_API_TOKEN' if buildkite_api_token.nil?

input_config = {}
OptionParser.new do |opts|
  add_commit_option(opts)
  opts.on('-b', '--branch BRANCH', String, 'The branch where the commit belongs')
  add_number_option(opts)
  add_organization_option(opts)
  add_pipeline_option(opts)
  opts.on('-a', '--author', String, 'The name of the build author that should appear on Buildkite')
  opts.on('-e', '--email', String, 'The email of the build author that should appear on Buildkite')
end.parse!(into: input_config)

# input configs override local ones
config = local_config.merge(input_config)

raise 'Missing commit' if config[:commit].nil?
raise 'Missing branch' if config[:branch].nil?
raise 'Missing pipeline' if config[:pipeline].nil?
raise 'Missing number of builds to spawn' if config[:number].nil?
raise 'Missing organization' if config[:organization].nil?
raise 'Missing author name' if config[:author].nil?
raise 'Missing author email' if config[:email].nil?

buildkite_api_token = ENV['BK_API_TOKEN']
raise 'Missing Buildkite API token as BK_API_TOKEN' if buildkite_api_token.nil?

base_url = "https://api.buildkite.com/v2/organizations/#{config[:organization]}"

message = 'Build to verify stability'

payload = {
  branch: config[:branch],
  commit: config[:commit],
  author: {
    name: config[:author],
    email: config[:email]
  },
  env: {},
  meta_data: {}
}

url = "#{base_url}/pipelines/#{config[:pipeline]}/builds"
(1..config[:number]).each do |i|
  suffix = "#{i} of #{config[:number]}"
  puts "Spawning build #{suffix}..."

  payload[:message] = "#{message} (#{suffix})"

  begin
    RestClient.post(url, payload.to_json, headers = { 'Authorization' => "Bearer #{buildkite_api_token}" })
  rescue RestClient::ExceptionWithResponse => e
    puts "Something went wrong"
    puts e.response
  end
end
