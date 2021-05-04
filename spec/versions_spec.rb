require "yaml"

RSpec.describe "Versions" do
  describe "Terraform" do
    canonical_terraform_version = File.read("terraform/.terraform-version").chomp

    describe "Concourse" do
      it "concourse/pipelines/deploy.yml should use the canonical terraform version (#{canonical_terraform_version})" do
        pipeline = YAML.load_file("concourse/pipelines/deploy.yml")
        terraform_image_tag = pipeline
          .dig("jobs").find { |job| job["name"] == "run-terraform" }
          .dig("plan").find { |stage| stage["task"] == "terraform-apply" }
          .dig("config", "image_resource", "source", "tag")

        expect(terraform_image_tag).to eql canonical_terraform_version
      end
    end

    describe "GitHub Actions" do
      it ".github/workflows/ci.yml should use the canonical terraform version (#{canonical_terraform_version})" do
        workflow = YAML.load_file(".github/workflows/ci.yml")
        terraform_version = workflow
            .dig("jobs", "test", "steps")
            .find { |step| step["uses"] == "hashicorp/setup-terraform@v1" }
            .dig("with", "terraform_version")
        expect(terraform_version).to eql canonical_terraform_version
      end
    end
  end
end
