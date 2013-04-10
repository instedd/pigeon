#= require pigeon/layout

class TwitterLayout extends PigeonLayout
  onAuthorized: ->
    $('.twitter_not_authorized').hide()
    $('.twitter_authorized').show()
    $('.screen_name').text(@screen_name.val())

  beginTwitterAuthorization: ->
    callback = 'pigeon_callback_' + (Math.round(Math.random() * 1000000))
    window[callback] = (token, secret, screen_name) =>
      @token.val(token)
      @secret.val(secret)
      @screen_name.val(screen_name)
      @onAuthorized()

    url = @twitter_auth_url + '?js_callback=' + callback
    window.open(url, 'pigeon_twitter', 'menubar=no,location=yes,width=593,height=533')

  run: ->
    @screen_name = @attribute('configuration[screen_name]')
    @token = @attribute('configuration[token]')
    @secret = @attribute('configuration[secret]')

    @button = $('.twitter_authorize_button')
    @twitter_auth_url = $(@div).data('twitter-path')

    if @screen_name.val() != ''
      @onAuthorized()
    else
      $('.twitter_not_authorized').show()
      $('.twitter_authorized').hide()

    @button.click =>
      @beginTwitterAuthorization()

PigeonLayout.registerClass 'twitter', TwitterLayout

