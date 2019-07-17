# Reacts to pipeline stack deployment status changes and notifies GitHub


require 'octokit'


def extract_variables(message)
  hash = {}

  message.each_line do |line|
    matches = line.scan(/^([^=]+)='(.+)'$/)

    variable = matches[1]
    value = matches[2]

    hash[variable] = value
  end

  return hash
end


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
      'context' => 'pipeline CloudFormation stack',
      'description' => 'Pipeline failed to deploy',
      'target_url' => 'https://console.aws.amazon.com/cloudformation/home?region={region}#/stacks/{StackName}/overview',
    },
  )
end


def process_message(message)
  vars = extract_variables(message)

  # Available variables:
  # StackId
  # Timestamp
  # EventId
  # LogicalResourceId
  # Namespace
  # PhysicalResourceId
  # PrincipalId
  # ResourceProperties
  # ResourceStatus
  # ResourceStatusReason
  # ResourceType
  # StackName
  # ClientRequestToken

  stack_name = vars['StackName']
  logical_resource_id = vars['LogicalResourceId']
  resource_type = vars['ResourceType']

  message_relates_to_stack_itself = stack_name == logical_resource_id and resource_type == 'AWS::CloudFormation::Stack'

  if message_relates_to_stack_itself
    resource_status = vars['ResourceStatus']

    github_status = cfn_status_github(resource_status)

    report_status(
      stack: stack_name,
      status: github_status,
    )
  end
end


def main(records)
  records.each do |record|
    object = record['Sns']
    subject = object['Subject']

    if subject == 'AWS CloudFormation Notification'
      message = object['Message']
      process_message(message)
    else
      # forged message!
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
