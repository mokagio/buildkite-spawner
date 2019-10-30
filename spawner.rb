buildkite_api_token = ENV['BK_API_TOKEN']
raise 'Missing Buildkite API token as BK_API_TOKEN' if buildkite_api_token.nil?

pipeline = ARGV[0]
raise 'Missing pipeline' if pipeline.nil?

branch = ARGV[1]
raise 'Missing branch' if branch.nil?

commit_full_sha = ARGV[2]
raise 'Missing commit full SHA' if commit_full_sha.nil?

total = ARGV[3].to_i
raise 'Missing number of builds to spawn' if total.nil?

organization = ARGV[4]
raise 'Missing organization' if organization.nil?

author_name = ARGV[5]
raise 'Missing author name' if author_name.nil?

author_email = ARGV[6]
raise 'Missing author email' if author_email.nil?

base_url = "https://api.buildkite.com/v2/organizations/#{organization}"

message = 'Build to verify stability'

(1..total).each do |i|
  system %Q{
curl \
  -H 'Authorization: Bearer #{buildkite_api_token}' \
  -X POST "#{base_url}/pipelines/#{pipeline}/builds" \
  -d '{
    "branch": "#{branch}",
    "commit": "#{commit_full_sha}",
    "message": "#{message} (#{i} of #{total})",
    "author": {
      "name": "#{author_name}",
      "email": "#{author_email}"
    },
    "env": { },
    "meta_data": { }
  }'
  }
  sleep(0.5) # just so we don't hit rate limiting
end
