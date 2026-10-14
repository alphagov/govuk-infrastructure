data "github_team" "push_allowance_teams" {
  for_each = toset([
    "gov-uk-production-admin",
    "gov-uk-production-deploy"
  ])

  slug = each.value
}

resource "github_repository_ruleset" "gouk_synthetic_test_app_canary_push" {
  name        = "main-branch-protection-push"
  repository  = "govuk-synthetic-test-app-canary"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = "5249013"
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  dynamic "bypass_actors" {
    for_each = data.github_team.push_allowance_teams
    content {
      actor_id    = bypass_actors.value.id
      actor_type  = "Team"
      bypass_mode = "always"
    }
  }

  rules {
    creation                = true
    update                  = true
    deletion                = false
    required_linear_history = false
    required_signatures     = false
    non_fast_forward        = true

  }
}

resource "github_repository_ruleset" "gouk_synthetic_test_app_canary_prs" {
  name        = "main-branch-protection-prs"
  repository  = "govuk-synthetic-test-app-canary"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = "5249013"
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    creation                = false
    update                  = false
    deletion                = true
    required_linear_history = false
    required_signatures     = false
    non_fast_forward        = true

    pull_request {
      required_approving_review_count = 1

      require_code_owner_review = false

      dismiss_stale_reviews_on_push = true
    }

    required_status_checks {
      strict_required_status_checks_policy = false

      required_check {
        context = "Test"
      }

      required_check {
        context = "CodeQL SAST scan / Analyze"
      }

      required_check {
        context = "Dependency Review scan / dependency-review-pr"
      }
    }
  }
}

