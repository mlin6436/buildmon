class Dashing.Jobalerter extends Dashing.Widget

  onData: (data) ->
    columns = $('[data-id="' + data.id + '"]').find(".col")
    columns.empty()
    @setBackground data.statuses
    components = @getComponents data.statuses
    
    result = ""
    for component in components
      result += component.soft_name + ", "
    result = result.slice(0, -2)
      
    div = @createDiv(data.statuses, result)
    leftColumn = $('[data-id="' + data.id + '"]').find(".left")
    leftColumn.append div

  getComponents: (statuses) ->
    switch true
      when "red" of statuses then statuses["red"]
      when "yellow" of statuses then statuses["yellow"]
      else null

  setBackground: (statuses) ->
    switch true
      when "red" of statuses then $(@node).css("background-color", "#ed4337")
      when "yellow" of statuses then $(@node).css("background-color", "#ffe711")
      else
        if Object.keys(statuses).length
          $(@node).css("background-color", "#3498db")
        else
          $(@node).css("background-color", "#38c143")

  createDiv: (statuses, names) ->
    switch true
      when "red" of statuses then '<li class="red job"><i class="fa fa-warning faa-flash animated"></i> '+names+'</li>'
      when "yellow" of statuses then '<li class="yellow job"><i class="fa fa-flash animated"></i> '+names+'</li>'
      when "disabled" of statuses then ''
      else '<li class="blue job flashing"><i class="fa fa-gears fa-spin"></i> '+names+'</li>'
