PROJECT_ROOT = File.dirname(__FILE__)
Dir[File.join(PROJECT_ROOT, "lib/tasks/**/*.rake")].each { |file| load file }
$LOAD_PATH << File.expand_path("../lib", __dir__)

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint test]
