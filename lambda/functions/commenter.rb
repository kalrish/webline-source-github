require 'octokit'


def send(message:, number:, owner:, repo:)
  path = "#{owner}/#{repo}"

  Octokit.add_comment(
    path,
    number,
    message,
  )
end


def handler(event:, context:)
  record = event['records'][0]

  message = record['message']
  number = record['number']
  owner = record['owner']
  repo = record['repo']

  send(
    message: message,
    number: number,
    owner: owner,
    repo: repo,
  )

  response = Null

  return response
end
