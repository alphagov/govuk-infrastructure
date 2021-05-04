desc "Run all linters"
task :lint do
  sh "bundle exec rubocop"
end
