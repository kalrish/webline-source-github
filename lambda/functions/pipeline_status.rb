# Reacts to pipeline status changes and notifies GitHub


def process_event(event)
end


def handler(event:, context:)
  records = event['Records']

  records.each do
    |record|

    event = record['events']

    process_event(event)
  end

  response = {
  }

  return response
end
