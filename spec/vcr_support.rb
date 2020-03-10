require "vcr"

RSpec.configure do |config|
  VCR.configure do |c|
    c.cassette_library_dir = "spec/cassettes"
    c.hook_into :webmock

    c.default_cassette_options = {record: :new_episodes, match_requests_on: [:path, :query]}
    c.allow_http_connections_when_no_cassette = false
    c.ignore_localhost = true
  end
end
