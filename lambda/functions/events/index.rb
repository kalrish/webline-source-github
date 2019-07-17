require 'json'


def process_record(record)
  message = record['Sns']['Message']

  event_data = JSON.parse(
    message,
  )

  process_event(
    event_data,
  )
end


def handler(event:, context:)
  # SNS passes exactly 1 record
  record = event['Records'][0]

  process_record(record)

  response = {
  }

  return response
end
