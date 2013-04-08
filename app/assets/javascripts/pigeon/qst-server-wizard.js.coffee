#= require pigeon/wizard

class QstServerWizard extends PigeonWizard
  selectPhoneType: (type) ->

  onPhoneType: (type) ->
    @pages.each (index, page) ->
      page = $(page)
      page_phone_type = $(page).data('phone-type')
      if page_phone_type
        page.disabled = page_phone_type != type
    @attribute('phone_type').val(type)

  initPhoneType: (type) ->
    $('[name=phone_type]').each (index, radio) ->
      $(radio).attr('checked', radio.value == type)
    @onPhoneType type

  run: ->
    @initPhoneType @attribute('phone_type').val()

    $('#phone_type_android').click =>
      @onPhoneType 'android'
    $('#phone_type_other').click =>
      @onPhoneType 'other'

    super

PigeonWizard.registerClass 'qst-server', QstServerWizard

