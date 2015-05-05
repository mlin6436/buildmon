class Dashing.Versioner extends Dashing.Widget

  onData: (data) ->
    $(@node).css("background-color", data.color)
    $(this).attr('data-id', data.id)

    $('[data-id="'+data.id+'"] .main').empty()
    if data.colCount is 1
      $('[data-id="'+data.id+'"] .main').css 
      for component, i in data.components
        $('[data-id="'+data.id+'"] .main').append @createDiv(component, 1)
    else
      $('[data-id="'+data.id+'"] .main').append '<div class="left"></div>'
      $('[data-id="'+data.id+'"] .main').append '<div class="right"></div>'
      for component, i in data.components
        if (i + 1) % 2
          $('[data-id="'+data.id+'"] .left').append @createDiv(component, 2)
        else
          $('[data-id="'+data.id+'"] .right').append @createDiv(component, 2)
    $('[data-id="'+data.id+'"] .version').css('font-size', data.fontSize)    

  createDiv: (component, colCount) ->
    result = '<div class="listitem col'+colCount+'" >'
    result += '<li class="name">'+component.name
    if component.rpmWarning
      result += '  <i class="animated faa-pulse fa fa-warning"></i>'
    if component.lastBuild
      if component.lastBuild == component.lastSuccessfulBuild
        result += ' [ <span class="build">'+component.lastBuild+' </span>]'
      else
        result += ' [ <span class="build">'+component.lastBuild+'</span><span class="build last-successful"> ( '+component.lastSuccessfulBuild+' ) </span>]</li>'
    result += '</li><li class="version"">'+component.version+'</li>'
    result += '</div>'
    return result
