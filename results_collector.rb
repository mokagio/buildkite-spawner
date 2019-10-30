require 'json'
require 'rest-client'
require 'optparse'

buildkite_api_token = ENV['BK_API_TOKEN']
raise 'Missing Buildkite API token as BK_API_TOKEN' if buildkite_api_token.nil?

options = {}
OptionParser.new do |opts|
  # TODO: add usage hey!
  # opts.banner = "Usage: example.rb [options]"

  opts.on('-c', '--commit SHA', String, 'The full SHA commit to spawn') do |sha|
    options[:commit] = sha
  end

  opts.on('-p', '--pipeline PIPELINE', String, 'The name of the pipeline on which to spawn builds') do |p|
    options[:pipeline] = p
  end

  opts.on('-n', '--number NUMBER', Integer, 'How many builds have been run') do |n|
    options[:number] = n
  end

  opts.on('-o', '--organization ORG', String, 'How many builds to run') do |o|
    options[:organization] = o
  end
end.parse!

raise 'Missing commit full SHA' if options[:commit].nil?
raise 'Missing pipeline' if options[:pipeline].nil?
raise 'Missing number of builds to check (this will become computed soon)' if options[:number].nil?
raise 'Missing organization' if options[:organization].nil?

base_url = "https://api.buildkite.com/v2/organizations/#{options[:organization]}"

# The API response is paginated, but without next page information (that I
# could find). This means we can't just get _all_ the builds for a given commit
# if we run more that 100. So, let's just get those that failed.
# See https://buildkite.com/docs/apis/rest-api/builds#list-builds-for-a-pipeline
url = "#{base_url}/pipelines/#{options[:pipeline]}/builds?commit=#{options[:commit]}&state=failed"
json = JSON.parse(RestClient.get(url, headers = { 'Authorization' => "Bearer #{buildkite_api_token}" }).body)

failed = json.map { |build| build['web_url'] }

success_rate = (100 - (failed.length.to_f / options[:number] * 100)).round(2)

puts "#{failed.length} out of #{options[:number]} failed for commit #{options[:commit]} (#{success_rate}% success rate)"

unless failed.empty?
  puts "\nFailed builds:"
  failed.reverse.each do |build_url|
    puts "- #{build_url}"
  end
end
