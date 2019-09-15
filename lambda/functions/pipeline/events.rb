require 'octokit'


def cfn_status_github(status:)
  something = true
  if status == 'CREATE_COMPLETE' or status == 'UPDATE_COMPLETE'
    something = true
  else
    something = false
  end
  return something
end


def report_status(stack:, status:)
  # We need the PR number
  # We have the stack ARN, from which we can get the client's account ID
  # We have the stack name, from which we *could* extract the repo and the PR
  # We also have the client token

  # octokit status API
  client = Octokit::Client.new(
    token: token,
  )

  client.create_status(
    repo: repository,
    sha: commit,
    state: status,
    options: {
      'context' => 'pipeline',
      'description' => 'Pipeline completed successfully',
      'target_url' => 'https://console.aws.amazon.com/cloudformation/home?region={region}#/stacks/{StackName}/overview',
    },
  )
end


def main()
  if check_pipeline_completed
    if pr_is_approved
      open_the_gate()
    end
  end

  if gate_pipeline_completed
    if pr_is_mergeable
      merge_pr()
    end
  end
end


def handler(event:, context:)
  records = event['Records']

  main(records)

  response = {
  }

  return response
end
