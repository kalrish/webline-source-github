require 'json'
require 'octokit'


def send(data:)
  message = data['message']
  number = data['number']
  owner = data['owner']
  repo = data['repo']

  path = "#{owner}/#{repo}"

  # FIXME: make sure that add_comment throws if it fails
  Octokit.add_comment(
    path,
    number,
    message,
  )
end


def handler(event:, context:)
  record = event['records'][0]

  data = JSON.parse(
    record,
  )

  send(
    data: data,
  )
end
