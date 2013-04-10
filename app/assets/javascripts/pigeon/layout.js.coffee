class PigeonLayout
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

window.PigeonLayout = PigeonLayout

jQuery.fn.pigeonLayout = ->
  @each (index, layout) ->
    type = $(layout).data('type')
    klass = PigeonLayout.klasses[type]
    if klass
      new klass(layout).run()
    else
      new PigeonLayout(layout).run()

jQuery ->
  $('.pigeon.pigeon_layout').pigeonLayout()

