class Dashing.Hawker extends Dashing.Widget

  ready: ->
    @lastMessager = ''
    return

  onData: (data) ->
    if data.clear?
      $('[data-id="'+data.id+'"] .post')
        .fadeOut(2000)
      callback = -> $('[data-id="'+data.id+'"] .post').remove()
      setTimeout callback, 2000
      @lastMessager = ''
    else
      @post data

  post: (data) ->
    if @lastMessager is data.name
      pos = $(".post:first").data("pos")
    else
      pos = switch $(".post:first").data("pos")
        when "left" then "right"
        else "left"
        
    div = '<div class="post" data-pos="'+pos+'">
      <div class="imgContainer '+pos+'">
      	<div class="img" style="background-image:url('+data.gravatar+');"></div>
         	</div>
         	<div class="msgContainer '+pos+'">
            <div class="msgAligner">
           		<div class="msg">'+data.message+'</div>
              <div class="msgTimeStamp">'+data.name+' - '+moment().format("ddd")+' @'+moment().format("HH:mm")+'</div>
           	</div>
         	</div>
        </div>'

    $('[data-id="'+data.id+'"] .feed')
      .prepend div
      .css("top", "-80px")

    $('[data-id="'+data.id+'"] .feed')
      .animate({top: '0px'}, 2000, 'easeOutBounce')

    if $('.post').length is 9
      $('.post')[8].remove()
        
    @lastMessager = data.name
