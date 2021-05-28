namespace :secretsmanager do
  desc "Wait for secrets to be set in SecretsManager"
  task :wait_for_secrets do
    application = ENV["APPLICATION"]
    variant = ENV["VARIANT"]
    app_config = JSON.parse(File.read("../app-terraform-outputs/#{application}.json"))

    credentials = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: ENV["ASSUME_ROLE_ARN"],
      role_session_name: "wait-for-#{application}-#{variant}-secrets",
    )
    secrets_client = Aws::SecretsManager::Client.new(
      region: ENV["AWS_REGION"],
      credentials: credentials,
    )

    required_secrets = app_config.dig(variant, "required_secrets")
    secrets = required_secrets.to_h { |arn| [arn, false] }
    attempts = 0
    max_attempts = 10

    until secrets.values.all? || attempts == max_attempts
      attempts += 1

      secrets.each do |secret_arn, set|
        next if set

        metadata = secrets_client.describe_secret(secret_id: secret_arn)
        versions = metadata.version_ids_to_stages
        next if versions.nil?

        has_current_version = versions.values.any? do |stages|
          stages.include?("AWSCURRENT")
        end

        secrets[secret_arn] = true if has_current_version
      end
      sleep(2**attempts) unless attempts == max_attempts
    end

    if secrets.values.all?
      puts "All secrets for #{application}:#{variant} are set."
    else
      unset = secrets.reject { |_secret, set| set }.keys
      puts "Timed out!"
      puts "The following secrets are unset:"
      unset.each { |secret| puts " • #{secret}" }
      exit 1
    end
  end

  desc "Autogenerate secret_key_base for Rails apps"
  task :autogenerate_secret_key_base do
    config = JSON.parse(File.read("../terraform-outputs/secret_key_bases.json"))

    credentials = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: ENV["ASSUME_ROLE_ARN"],
      role_session_name: "create-rails-app-secret_key_base",
    )
    secrets_client = Aws::SecretsManager::Client.new(
      region: ENV["AWS_REGION"],
      credentials: credentials,
    )

    config.fetch("arns").each do |secret_arn|
      metadata = secrets_client.describe_secret(secret_id: secret_arn)
      versions = metadata.version_ids_to_stages
      already_set = !versions.nil? && versions.values.any? do |stages|
        stages.include?("AWSCURRENT")
      end

      if already_set
        puts "Secret #{secret_arn} already set; skipping. 🔒"
        next
      end

      secrets_client.put_secret_value(
        secret_id: secret_arn,
        secret_string: SecureRandom.hex(64),
        version_stages: %w[AWSCURRENT],
      )

      puts "Generated secret_key_base for #{secret_arn} 🔑"
    end

    puts "Done! All secrets generated. 🔐"
  end
end
