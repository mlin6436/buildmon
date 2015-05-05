class Dashing.Opsticket extends Dashing.Widget

  # Clean Code

  ready: ->
    @set "widget", $("#"+@get('id'))
    @set "countdownDate", new Date()
    singleTimerController.registerWidget(this, @tickCallback)

  addTrailingZero: (i) ->
    if i < 10 then "0" + i else i

  tickCallback : ( current_timestamp ) =>
    end_timestamp = @get('countdownDate').getTime()

    ms_to_end = end_timestamp - current_timestamp
    s_to_end = Math.round(ms_to_end/1000)

    d = Math.floor(s_to_end/86400)
    h = Math.floor((s_to_end-(d*86400))/3600)
    m = Math.floor((s_to_end-(d*86400)-(h*3600))/60)
    s = s_to_end-(d*86400)-(h*3600)-(m*60)

    @get('widget').find('.d').text(if d >= 0 then @addTrailingZero(d) else "00")
    @get('widget').find('.h').text(if d >= 0 then @addTrailingZero(h) else "00")
    @get('widget').find('.m').text(if d >= 0 then @addTrailingZero(m) else "00")
    @get('widget').find('.s').text(if d >= 0 then @addTrailingZero(s) else "00")

  createTickBox: (count) ->
    result = ""
    for i in [0..2]
      result += if i < count then '<li class="title tick fa fa-check-square-o"></li>' else '<li class="info tick fa fa-square-o"></li>'
    return result

  createMessageDiv: (t, b, icon) ->
    result = '<div><span class="text msg-label">'+t+'</span>'
    result += '<br/><li class="'+icon+'"></li><br/>'
    result += '<span class="text msg-label">'+b+'</span></div>'
    @get('widget').find('.msg-container').empty()
      .append(result)

  updateCSSColors: (color) ->
    $(@node).css("background-color", color)
    bg = $.Color(@get("widget").css('backgroundColor'))
    color = if bg.lightness() > 0.5 then "0,0,0" else "255,255,255"

    classes = [".title", ".label", ".info"]
    @get('widget').find(c).css("color", @get('widget').find(c).css("color").replace(/([0-9]+,\ )+/g, color + ", ")) for c in classes

  hideTimer: ->
    @get('widget').addClass("hide-timer")

  showTimer: ->
    @get('widget').removeClass("hide-timer")

  onData: (data) ->
    return unless this.get('widget')
    
    if data.msg
      @hideTimer()
      @createMessageDiv(data.msgSummary, data.msg, data.msgIcon)
    else
      @set 'countdownDate', new Date ( data.countdownDate )
      @get('widget').find('.ticket-summary').text(data.ticketSummary)
      @get('widget').find('.timer-summary')
        .empty()
        .append(data.timerSummary)    

    @get('widget').find('.tick-box').empty()
      .append @createTickBox(data.statusCount)

    if data.color
      @updateCSSColors(data.color)
