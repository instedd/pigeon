#= require pigeon/template

class TwilioTemplate extends PigeonTemplate
  checkCredentials: =>
    account_sid = @attribute('configuration[account_sid]').val()
    auth_token = @attribute('configuration[auth_token]').val()

    if account_sid != @account_sid || auth_token != @auth_token
      @account_sid = account_sid
      @auth_token = auth_token

      if $.trim(@account_sid).length > 0 && $.trim(@auth_token).length > 0
        client = new TwilioClient(@div, @account_sid, @auth_token)

        phones_div = $('#twilio-phone-number-div')
        phones_div.hide()

        feedback = $('#twilio-feedback-div')
        feedback.text("Fetching phone numbers from your account, please wait...")
        feedback.show()

        client.get_incoming_phone_numbers
          success: (data) =>
            @phone_numbers = data
            if @phone_numbers.length == 0
              feedback.text("It seems you don't have any phone number in your twilio account. Please buy one and then come back to this page.")
            else
              phone_select = $('#twilio-phone-number')
              options = ""
              for phone in @phone_numbers
                options += "<option name=\"#{phone.phone_number}\">#{phone.friendly_name}</option>"
              phone_select.html(options)

              phones_div.show()
              feedback.hide()
          error: =>
            feedback.text("Couldn't authenticate with Twilio.\nPlease check that you account sid and auth token are correct.")

  run: ->
    setInterval @checkCredentials, 500

    password_field = @attribute('configuration[incoming_password]')
    if password_field.val() == ''
      password_field.val(@generatePassword())

  class TwilioClient
    constructor: (@div, @account_sid, @auth_token) ->

    get_incoming_phone_numbers: (options) ->
      url = $(@div).data('twilio-get-incoming-numbers-path')
      $.ajax
        url: url
        type: "GET"
        data:
          account_sid: @account_sid
          auth_token: @auth_token
        success: options.success
        error: options.error

PigeonTemplate.registerClass 'twilio', TwilioTemplate
