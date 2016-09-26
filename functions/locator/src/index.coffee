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

getWelcomeResponse = (intent, session) ->
  buildResponse(
    'Welcome'
    'Welcome to the Alexa Skills Kit sample. Please tell me your favorite color
      by saying, my favorite color is red'
    reprompt: 'Please tell me your favorite color by saying my favorite color is
      red')

handleSessionEndRequest = (intent, session) ->
  buildResponse(
    'Session Ended'
    'Thank you for trying the Alexa Skills Kit sample. Have a nice day!'
    endSession: true)

###
# Sets the color in the session and prepares the speech to reply to the user.
###

setColorInSession = (intent, session) ->
  favoriteColorSlot = intent.slots.Color
  if favoriteColorSlot
    favoriteColor = favoriteColorSlot.value
    session = favoriteColor: favoriteColor
    speech = "I now know your favorite color is #{favoriteColor}. You can
      ask me your favorite color by saying, what\'s my favorite color?"
    reprompt = 'You can ask me your favorite color by saying, what\'s my
      favorite color?'
  else
    speech = 'I\'m not sure what your favorite color is. Please try again.'
    reprompt = 'I\'m not sure what your favorite color is. You can tell me your
      favorite color by saying, my favorite color is red'
  buildResponse intent.name, speech, reprompt: reprompt, session: session

getColorFromSession = (intent, session) ->
  endSession = false
  favoriteColor = session.attributes.favoriteColor if session.attributes
  if favoriteColor
    speech = "Your favorite color is #{favoriteColor}. Goodbye."
    endSession = true
  else
    speech = 'I\'m not sure what your favorite color is, you can say, my
      favorite color is red'
  # Setting repromptText to null signifies that we do not want to reprompt the
  # user.  If the user does not respond or says something that is not
  # understood, the session will end.
  buildResponse intent.name, speech,
    endSession: endSession,

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
  getWelcomeResponse()

###
# Called when the user specifies an intent for this skill.
###

intentHandlers =
  MyColorIsIntent: setColorInSession
  WhatsMyColorIntent: getColorFromSession
  'AMAZON.HelpIntent': getWelcomeResponse
  'AMAZON.StopIntent': handleSessionEndRequest
  'AMAZON.CancelIntent': handleSessionEndRequest

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
    console.log event.request.type
    handler = "on#{event.request.type.replace 'Request', ''}"
    console.log handler
    console.log eventHandlers[handler]
    callback null, eventHandlers[handler] event.request, event.session
  catch err
    callback err
