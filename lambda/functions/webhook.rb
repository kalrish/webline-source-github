# Receives and checks GitHub events and forwards them to the dispatch topic.


require 'aws-sdk-secretsmanager'
require 'aws-sdk-sns'
require 'net/http'
require 'openssl'
require 'rack'


def get_github_token(github_token_secret_arn)
  client = Aws::SecretsManager::Client.new()

  response = client.get_secret_value(
    {
      secret_id: github_token_secret_arn,
    },
  )

  github_token = response['secret_string']

  return github_token
end


def compute_signature(body:, token:)
  sha1_digest = OpenSSL::Digest.new('sha1')

  signature = OpenSSL::HMAC.hexdigest(
    sha1_digest,
    token,
    body,
  )

  return signature
end


def signature_valid?(computed:, received:)
  reference = 'sha1=' + computed

  # secure_compare protects us from timing attacks
  # see https://codahale.com/a-lesson-in-timing-attacks/
  match? = Rack::Utils.secure_compare(
    received,
    reference,
  )

  return match?
end


def main(body:, events_topic:, github_token_secret:, headers:)
  received_signature = headers['X-Hub-Signature']

  if received_signature
    github_token = get_github_token(
      github_token_secret,
    )

    computed_signature = compute_signature(
      body: body,
      token: github_token,
    )

    signature_validity = signature_valid?(
      computed_signature,
      received_signature,
    )

    if signature_validity
      event_name = headers['X-GitHub-Event']

      sns = Aws::SNS::Client.new()

      sns.publish(
        {
          topic_arn: events_topic,
          message: body,
          message_attributes: {
            'String' => {
              data_type: 'String',
              event: event_name,
            },
          },
        },
      )

      status_code = Net::HTTPAccepted
    else
      status_code = Net::HTTPUnauthorized
    end
  else
    status_code = Net::HTTPUnauthorized
  end

  return status_code
end


def handler(event:, context:)
  # Lambda function configuration
  github_token_secret = ENV['GITHUB_TOKEN_SECRET']
  events_topic = ENV['EVENTS_TOPIC']

  body = event['body']
  headers = event['headers']

  begin
    status_code = main(
      body: body,
      events_topic: events_topic,
      github_token_secret: github_token_secret,
      headers: headers,
    )
  rescue
    status_code = Net::HTTPInternalServerError
  end

  response = {
    'statusCode' => status_code,
    'headers': {
    },
    'body': '',
  }

  return response
end
