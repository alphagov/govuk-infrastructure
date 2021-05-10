desc "Run all tests"
task :test do
  sh "bundle exec rspec"
end
