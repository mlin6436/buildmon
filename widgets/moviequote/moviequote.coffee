class Dashing.Moviequote extends Dashing.Widget

  ready: ->
    @setWidth()

  setWidth: ->
    $('.msg-container').css("width", (parseInt($(@node).css("width")) - 190) + "px")
    $('.reveal-time').css("width", (parseInt($(@node).css("width")) - 190) + "px")

  onData: (data) ->
    $(this).attr('data-id', data.id)
    @setWidth()
    
    target_time = new Date( new Date().getTime() + ( data.revealTime * 1000 ) )

    returnQuote = ->
      $('[data-id="'+data.id+'"] .msg-container').fadeOut(5000)

      callback = ->
        $('[data-id="'+data.id+'"] .quote').text(data.quote)
        $('[data-id="'+data.id+'"] .actor').text(data.actor)
        $('[data-id="'+data.id+'"] .reveal-time').fadeIn(5000)
        $('[data-id="'+data.id+'"] .msg-container').fadeIn(5000)
      setTimeout callback, 5000
    
    revealFilm = ->
      $('[data-id="'+data.id+'"] .msg-container').fadeOut(5000)
      $('[data-id="'+data.id+'"] .reveal-time').fadeOut(5000)

      callback = ->
        $('[data-id="'+data.id+'"] .quote').text(data.film)
        $('[data-id="'+data.id+'"] .actor').text('')
        $('[data-id="'+data.id+'"] .reveal-time').empty()
        $('[data-id="'+data.id+'"] .msg-container').fadeIn(5000)
      setTimeout callback, 5000

    setTimeout returnQuote, ( data.revealTime * 2000 ) + 10000
    countdown = new Countdown({
      selector   : '.reveal-time',
      dateStart  : new Date(),
      dateEnd    : new Date(new Date().getTime() + (data.revealTime * 1000)),
      msgPattern : '{minutes} minutes and {seconds} seconds',
      msgAfter   : ''
      onEnd      : revealFilm
    })
