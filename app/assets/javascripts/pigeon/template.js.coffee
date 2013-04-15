class PigeonTemplate
  @klasses = {}

  @registerClass: (type, klass) ->
    @klasses[type] = klass

  constructor: (@div) ->
    div = $(@div)
    @scope = div.data('scope')
    @channel_name = div.data('name')
    @channel_kind = div.data('kind')
    @persisted = div.data('persisted')
    @app_name = div.data('application-name') || 'Pigeon'

  scoped_name: (name) ->
    if @scope
      bracket = name.indexOf('[')
      if bracket >= 0
        @scope + '[' + name[0..bracket-1] + ']' + name[bracket..-1]
      else
        @scope + '[' + name + ']'
    else
      name

  attribute: (name) ->
    $("[name=\"#{@scoped_name(name)}\"]", @div)

  run: ->

window.PigeonTemplate = PigeonTemplate

jQuery.fn.pigeonTemplate = ->
  @each (index, template) ->
    type = $(template).data('type')
    klass = PigeonTemplate.klasses[type]
    if klass
      new klass(template).run()
    else
      new PigeonTemplate(template).run()

jQuery ->
  $('.pigeon.pigeon_template').pigeonTemplate()

