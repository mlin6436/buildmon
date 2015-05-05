class Dashing.JenkinsBuild extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue      
  @accessor 'class', ->
    if @get('currentResult') == "SUCCESS"
      "widget-jenkins-build widget-jenkins-build--success"
    else if @get('currentResult') == "FAILURE"
      "widget-jenkins-build widget-jenkins-build--failure"
    else if @get('currentResult') == "PREBUILD"
      "widget-jenkins-build widget-jenkins-build--prebuild"
    else
      "widget-jenkins-build"

  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".jenkins-build").val(value).trigger('change')

  ready: ->
    meter = $(@node).find(".jenkins-build")
    $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()

  onData: (data) ->
   if data.currentResult isnt data.lastResult
     $(@node).fadeOut().attr('class',@get('class')).fadeIn()