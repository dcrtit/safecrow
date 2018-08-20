require "bundler/setup"
require "safecrow"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  config.before(:all) do
    Safecrow.configure do |config|
      config.url = ENV["URL"]
      config.apikey = ENV["APIKEY"]
      config.apisecret = ENV["APISECRET"]
      config.prefix = ENV["PREFIX"]
    end
  end
end
