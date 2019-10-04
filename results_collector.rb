require 'rest-client'
require 'json'

buildkite_api_token = ENV['BK_API_TOKEN']
raise 'Missing Buildkite API token as BK_API_TOKEN' if buildkite_api_token.nil?

commit = ARGV[0]
raise 'Missing commit full SHA' if commit.nil?

pipeline = ARGV[1]
raise 'Missing pipeline' if pipeline.nil?

# TODO: it would be better to computed this by following the pagination of the
# response, but I haven't figured it out yet
total_buids = ARGV[2].to_i
raise 'Missing number of total builds' if total_buids.nil?

organization = ARGV[3]
raise 'Missing organization' if organization.nil?

base_url = "https://api.buildkite.com/v2/organizations/#{organization}"

# The API response is paginated, but without next page information (that I
# could find). This means we can't just get _all_ the builds for a given commit
# if we run more that 100. So, let's just get those that failed.
# See https://buildkite.com/docs/apis/rest-api/builds#list-builds-for-a-pipeline
url = "#{base_url}/pipelines/#{pipeline}/builds?commit=#{commit}&state=failed"
json = JSON.parse(RestClient.get(url, headers = { 'Authorization' => "Bearer #{buildkite_api_token}" }).body)

failed = json.map { |build| build['web_url'] }

success_rate = (100 - (failed.length.to_f / total_buids * 100)).round(2)

puts "#{failed.length} out of #{total_buids} failed for commit #{commit} (#{success_rate}% success rate)"

unless failed.empty?
  puts "\nFailed builds:"
  failed.reverse.each do |build_url|
    puts "- #{build_url}"
  end
end
