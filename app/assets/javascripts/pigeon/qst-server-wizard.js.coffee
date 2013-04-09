#= require pigeon/wizard

class QstServerWizard extends PigeonWizard
  onPhoneType: (type) ->
    @pages.each (index, page) ->
      page_phone_type = $(page).data('phone-type')
      if page_phone_type
        page.disabled = page_phone_type != type
      true
    @attribute('phone_type').val(type)
    @updateNavigation()

  initPhoneType: (type) ->
    @phone_type_radios.each (index, radio) ->
      $(radio).attr('checked', radio.value == type)
    @onPhoneType type

  generatePassword: (length = 8) ->
    charset = "abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    retVal = ""
    n = charset.length
    for i in [0..length]
      retVal += charset.charAt(Math.floor(Math.random() * n))
    retVal

  run: ->
    self = this

    @ticket_code_fields = $('.ticket_code', @div)
    @phone_type_radios = $('.phone_type', @div)

    @initPhoneType @attribute('phone_type').val()
    @phone_type_radios.click ->
      self.onPhoneType @value

    @ticket_code_fields.change ->
      # update both ticket_cde fields to make sure the current value gets posted
      self.attribute('ticket_code').val(@value)

    password_field = @attribute('configuration[password]')
    if password_field.val() == ''
      password_field.val(@generatePassword())

    super

PigeonWizard.registerClass 'qst-server', QstServerWizard

