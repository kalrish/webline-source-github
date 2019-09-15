# Handles PR-related events


require 'aws-sdk-s3'
require 'json'


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


def notify_github(result:)
  # Changeset empty
  message = 'Pipeline triggered.'

  # Changeset not empty
  message = ''

  call_integration_github_commenter(
    message: message,
  )
end


def process_event(event_data)
  github_token_secret = ENV['GITHUB_TOKEN_SECRET']
  pipeline_stack_notification_topic = ENV['PIPELINE_STACK_NOTIFICATION_TOPIC']
  webpipe_bucket = ENV['WEBPIPE_BUCKET']

  owner = event_data['repository']['owner']['login']
  repository = event_data['repository']['name']
  pr_number = event_data['pull_request']['id']

  upload_configuration(
    branch: branch,
    bucket: bridge_bucket,
    owner: owner,
    repository: repository,
  )

  result = call_core_pipeline_deployer()

  notify_github_inprogress(
    result: result,
  )
end
