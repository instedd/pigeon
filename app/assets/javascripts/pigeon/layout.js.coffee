class PigeonLayout
  constructor: (@div) ->
    @scope = $(@div).data('scope')
    @channel_name = $(@div).data('name')
    @channel_kind = $(@div).data('kind')
    @persisted = $(@div).data('persisted')

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
    new PigeonLayout(layout).run()

jQuery ->
  $('.pigeon.pigeon_layout').pigeonLayout()

