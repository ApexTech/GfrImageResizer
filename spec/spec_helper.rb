require "dotenv/load"
require "bundler/setup"
require "webmock/rspec"
require "gfr_image_transformer"
require "awesome_print"

WebMock.disable_net_connect!(allow_localhost: true)

require "vcr_support"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
