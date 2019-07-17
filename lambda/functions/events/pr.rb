# Handles PR-related events


require 'aws-sdk-cloudformation'
require 'aws-sdk-s3'
require 'json'
require 'octokit'


def upload_configuration(bucket:, owner:, repository:, branch:)
  client = Aws::S3::Client.new()

  codepipeline_source_configuration = {
    'Owner' => owner,
    'Repo' => repo,
    'Branch' => branch,
    'PollForSourceChanges' => false,
    'OAuthToken' => "{{resolve:secretsmanager:#{github_token_secret_name}}}",
  }

  json_body = JSON.generate(codepipeline_source_configuration)

  response = client.put_object(
    bucket: bucket,
    key: "#{owner}/#{repository}/#{branch}/pipeline.json",
    body: json_body,
  )
end


def pipeline_deployed?(branch:, repository:)
  client = Aws::CloudFormation::Client.new()

  response = {}

  pipeline_stack_exists = false

  return pipeline_stack_exists
end


def deploy_pipeline(bucket:, role:, sns_arn:)
  client = Aws::CloudFormation::Client.new()

  response = client.create_stack(
    stack_name: "webpipe-pipeline-#{owner}-#{repository}-#{branch}",
    template_url: "https://#{bucket}.s3.amazonaws.com/v1/cfn/pipeline.yaml",
    parameters: [
      {
        parameter_key: 'WebpipeBucket',
        parameter_value: bucket,
      },
      {
        parameter_key: 'Branch',
        parameter_value: branch,
      },
      {
        parameter_key: 'SourceProvider',
        parameter_value: 'github',
      },
    ],
    capabilities: [
      'CAPABILITY_IAM',
    ],
    role_arn: role,
    notification_arns: [
      sns_arn,
    ],
    tags: [
      {
        key: 'GitHub-Owner',
        value: owner,
      },
      {
        key: 'GitHub-Repo',
        value: repo,
      },
    ],
  )
end


def process_event(event_data)
  github_token_secret = ENV['GITHUB_TOKEN_SECRET']
  pipeline_stack_notification_topic = ENV['PIPELINE_STACK_NOTIFICATION_TOPIC']
  webpipe_bucket = ENV['WEBPIPE_BUCKET']

  owner = event_data['repository']['owner']['login']
  repository = event_data['repository']['name']
  pr_number = event_data['pull_request']['id']

  role = get_customer_role_from_repo_branch()

  assume_role(role)

  upload_configuration(
    bucket: bridge_bucket,
    owner: owner,
    repository: repository,
    branch: branch,
  )

  pipeline_deployed = pipeline_deployed?(
    branch: branch,
    repository: repository,
  )

  if not pipeline_deployed?(branch)
    deploy_pipeline(
      bucket: webpipe_bucket,
      role: pipeline_stack_deployment_role,
      sns_arn: pipeline_stack_notification_topic,
      owner: owner,
      repository: repository,
      branch: branch,
    )
  end

  trigger_pipeline(
  )

  github_token = get_github_token(github_token_secret)

  notify_github_inprogress(
    token: github_token,
  )
end
