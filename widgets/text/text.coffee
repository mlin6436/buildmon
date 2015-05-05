class Dashing.Text extends Dashing.Widget

  onData: (data) ->
    $(@node).css("background-color", data.color)
    $(this).attr('data-id', data.id)
    
    $('[data-id="'+data.id+'"] [data-bind="moreinfo"]').text(data.moreinfo)
    
    $('[data-id="'+data.id+'"] [data-bind="text"]').text(data.info)
    $('[data-id="'+data.id+'"] [data-bind="text"]').css('font-size', data.fontSize)
    $('[data-id="'+data.id+'"] [data-bind="text"]').css('color', data.fontColor)
