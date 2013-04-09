#= require pigeon/layout

class PigeonWizard extends PigeonLayout
  @klasses = {}

  @registerClass: (type, klass) ->
    @klasses[type] = klass

  constructor: (@div) ->
    super
    @prevButton = $('<button type="button">Prev</button>')
    @nextButton = $('<button type="button">Next</button>')
    @pages = $(@div).find('.pigeon_wizard_page')
    @navigation = $('<div class="pigeon_wizard_navigation"></div>').append(@prevButton).append(@nextButton).appendTo(@div)
    @current = -1

    @prevButton.click =>
      prev = @prevActivePage(@current)
      @selectPage prev if prev >= 0

    @nextButton.click =>
      next = @nextActivePage(@current)
      @selectPage next if next >= 0
              
  prevActivePage: (index) ->
    index--
    while index >= 0 && @pages[index].disabled
      index--
    index

  nextActivePage: (index) ->
    index++
    while index < @pages.length && @pages[index].disabled
      index++
    if index >= @pages.length then -1 else index

  selectPage: (index) ->
    $(@pages[@current]).removeClass('active') unless @current < 0
    $(@pages[index]).addClass('active')
    @current = index
    @updateNavigation()

  updateNavigation: ->
    if @prevActivePage(@current) < 0
      @prevButton.attr('disabled', 'disabled')
    else
      @prevButton.removeAttr('disabled')
    if @nextActivePage(@current) < 0
      @nextButton.attr('disabled', 'disabled')
    else
      @nextButton.removeAttr('disabled')
    
  selectDefaultPage: ->
    # If any active page has a field with an error, select that
    # Otherwise, select the first active page
    pages_with_errors = $('.field_with_errors').
      parents('.pigeon_wizard_page').filter -> !@disabled
    found = -1
    if pages_with_errors.length > 0
      pages_with_errors.each (index, page) =>
        index_in_pages = $.inArray(page, @pages)
        if found < 0 || (index_in_pages >= 0 && index_in_pages < found)
          found = index_in_pages

    if found >= 0
      @selectPage found
    else
      @selectPage @nextActivePage(-1)

  run: ->
    @selectDefaultPage()
    
  generatePassword: (length = 8) ->
    charset = "abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    retVal = ""
    n = charset.length
    for i in [0..length]
      retVal += charset.charAt(Math.floor(Math.random() * n))
    retVal


window.PigeonWizard = PigeonWizard

jQuery.fn.pigeonWizard = ->
  @each (index, wizard) ->
    type = $(wizard).data('type')
    klass = PigeonWizard.klasses[type]
    if klass
      new klass(wizard).run()
    else
      new PigeonWizard(wizard).run()

jQuery ->
  $('.pigeon.pigeon_wizard').pigeonWizard()

