#!/usr/bin/env ruby
require 'aws-sdk-ecs'

%w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION).each do |envvar|
  next if ENV.key?(envvar) && !ENV[envvar].nil?
  raise StandardError, "Environment variable #{envvar} is required!"
end

application, build_tag = ARGV[0..1]

raise StandardError, "application and build_tag required" unless application && build_tag

def build_new_revision(task_definition, new_image_tag, container_definition_name)
  definition = task_definition.to_h
  definition[:container_definitions] = task_definition.to_h.dig(:container_definitions).map do |container|
    container[:image] = new_image_tag if container[:name] == container_definition_name
    container
  end
  %i[task_definition_arn revision status requires_attributes compatibilities].each do |key|
    definition.delete(key)
  end
  definition
end

ecs_client = Aws::ECS::Client.new
latest_active_revision = ecs_client.describe_task_definition({
  task_definition: application
}).task_definition

image = "govuk/#{application}:#{build_tag}"
next_revision = build_new_revision(latest_active_revision, image, application)

puts ecs_client.register_task_definition(next_revision).task_definition.task_definition_arn
