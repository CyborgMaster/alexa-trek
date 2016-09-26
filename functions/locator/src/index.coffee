###
# This sample demonstrates a simple skill built with the Amazon Alexa Skills
# Kit.  The Intent Schema, Custom Slots, and Sample Utterances for this skill,
# as well as testing instructions are located at http://amzn.to/1LzFrj6
#
# For additional samples, visit the Alexa Skills Kit Getting Started guide at
# http://amzn.to/1LGWsLG
###

# -------------- Helpers that build all of the responses -----------------------

buildResponse = (title, output, { reprompt, session, endSession }) ->
  endSession ?= false

  version: '1.0'
  sessionAttributes: session
  response:
    outputSpeech:
      type: 'PlainText'
      text: output
    card:
      type: 'Simple'
      title: title
      content: output
    reprompt: outputSpeech:
      type: 'PlainText'
      text: reprompt
    shouldEndSession: endSession

# ---------- Functions that control the skill's behavior -----------------------

welcome = (intent, session) ->
  buildResponse(
    'Welcome'
    'What is your inquiry?'
    reprompt: 'Please state your inquiry')

sessionEnd = (intent, session) ->
  buildResponse(
    'Goodbye'
    'Goodbye'
    endSession: true)

locations =
  captain: 'on the bridge. I mean in his office.'
  commander: 'in the mess hall'
  ensign: 'napping in his quarters, on deck 2'

locate = (intent, session) ->
  rank = intent.slots.Rank.value
  if rank?
    speech = "#{rank} Mickelson is #{locations[rank]}"
    buildResponse intent.name, speech, endSession: true
  else
    welcome()

# --------------- Events -----------------------

###
# Called when the session starts.
###
eventHandlers = {}

eventHandlers.onSessionStarted = (sessionStartedRequest, session) ->
  console.log "onSessionStarted requestId=#{sessionStartedRequest.requestId},
    sessionId=#{session.sessionId}"

###
# Called when the user launches the skill without specifying what they want.
###

eventHandlers.onLaunch = (launchRequest, session) ->
  console.log "onLaunch requestId=#{launchRequest.requestId},
    sessionId=#{session.sessionId}"
  # Dispatch to your skill's launch.
  welcome()

###
# Called when the user specifies an intent for this skill.
###

intentHandlers =
  LocateIntent: locate
  'AMAZON.HelpIntent': welcome
  'AMAZON.StopIntent': sessionEnd
  'AMAZON.CancelIntent': sessionEnd

eventHandlers.onIntent = (intentRequest, session) ->
  console.log "onIntent requestId=#{intentRequest.requestId},
    sessionId=#{session.sessionId}"
  intent = intentRequest.intent
  handler = intentHandlers[intent.name]
  throw new throw new Error('Invalid intent') unless handler?
  handler intent, session

###
# Called when the user ends the session.
# Is not called when the skill returns shouldEndSession=true.
###

eventHandlers.onSessionEnded = (sessionEndedRequest, session) ->
  console.log "onSessionEnded requestId=#{sessionEndedRequest.requestId},
    sessionId=#{session.sessionId}"
  # Add cleanup logic here

# --------------- Main handler -----------------------
# Route the incoming request based on type (LaunchRequest, IntentRequest,
# etc.) The JSON body of the request is provided in the event parameter.

exports.handle = (event, context, callback) ->
  try
    console.log "event.session.application.applicationId=
      #{event.session.application.applicationId}"

    ###
    # Uncomment this if statement and populate with your skill's application ID
    # to prevent someone else from configuring a skill that sends requests to
    # this function.
    ###

    ###
    if (event.session.application.applicationId !=
      'amzn1.echo-sdk-ams.app.[unique-value-here]') {
         callback('Invalid Application ID');
    }
    ###

    if event.session.new
      eventHandlers.onSessionStarted event.request, event.session
    handler = "on#{event.request.type.replace 'Request', ''}"
    callback null, eventHandlers[handler] event.request, event.session
  catch err
    callback err
