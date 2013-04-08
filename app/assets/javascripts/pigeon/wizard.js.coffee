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
    $('<div class="pigeon_wizard_navigation"></div>').append(@prevButton).append(@nextButton).appendTo(@div)
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
    if @prevActivePage(index) < 0
      @prevButton.attr('disabled', 'disabled')
    else
      @prevButton.removeAttr('disabled')
    if @nextActivePage(index) < 0
      @nextButton.attr('disabled', 'disabled')
    else
      @nextButton.removeAttr('disabled')
    
  run: ->
    @selectPage @nextActivePage(-1)
    

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
