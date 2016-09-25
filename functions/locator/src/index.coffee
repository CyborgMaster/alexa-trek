# This is triggered by a Cron event from AWS CloudWatch to kick off the
# workflow.

getLock = require 'getLock'
startWorkflow = require 'startWorkflow'

exports.handle = (event, context, callback) ->
  console.log 'Received event:', JSON.stringify(event, null, 2)

  getLock("#{context.functionName}/#{event.id}", value: context.awsRequestId)
    .then ->
      startWorkflow('CommEngineWorkflow.run',
        version: '1.1',
        input: "---\n- :current_date: !ruby/object:DateTime #{event.time}\n")
    .catch ->
      callback 'Got duplicate event! Skipping workflow invocation.'
