require 'yaml'

YamlPath = Struct.new(:file, :path)

RSpec.describe "Versions" do
  describe "Terraform" do
    canonical_terraform_version = File.read("terraform/.terraform-version").chomp

    describe "Concourse" do
      paths = [
        YamlPath.new("concourse/pipelines/deploy.yml", ["jobs", 1, "plan", 1, "config", "image_resource", "source", "tag"]),
        YamlPath.new("concourse/tasks/update-task-definition.yml", ["image_resource", "source", "tag"]),
      ]

      paths.each do |yaml_path|
        it "#{yaml_path.file} should use the canonical terraform version (#{canonical_terraform_version})" do
          yaml = YAML.load_file(yaml_path.file)
          terraform_image_tag = yaml.dig(*yaml_path.path)
          expect(terraform_image_tag).to eql "terraform-#{canonical_terraform_version}"
        end
      end
    end

    describe "GitHub Actions" do
      paths = [
        YamlPath.new(".github/workflows/ci.yml", ["jobs", "test", "steps", 1, "with", "terraform_version"])
      ]

      paths.each do |yaml_path|
        it "#{yaml_path.file} should use the canonical terraform version (#{canonical_terraform_version})" do
          yaml = YAML.load_file(yaml_path.file)
          terraform_version = yaml.dig(*yaml_path.path)
          expect(terraform_version).to eql canonical_terraform_version
        end
      end
    end

  end
end
