require "rake"
require "climate_control"
require "webmock/rspec"
$LOAD_PATH << File.expand_path("../lib", __dir__)

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = "doc"

  config.before(:suite) do
    Dir.glob("lib/tasks/*.rake").each { |r| Rake::DefaultLoader.new.load r }
    Dir.glob("./spec/factories/*.rb").sort.each { |f| require f }
  end
end

def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end

WebMock.disable_net_connect!(allow_localhost: false)
