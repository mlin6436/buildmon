class Dashing.Producthealth extends Dashing.Widget

  ready: ->
    @time_events = {}
    @cached_div = {}
    @cached_div_status = {}
    @is_first_load = true

  onData: (data) ->
    console.log("received data: " + data, data)
    if data.curl? or data.uncurl?
      @handleCurl data
      return

    if @is_first_load
      @is_first_load = false
      @draw data

    @update data

  update: (data) ->
    for component in data.components
      div = @createDiv component
      sanitised = @sanitiseId(component.name)
      if $('[data-id="'+data.id+'"] #'+sanitised+".merge").length
        @cached_div[component.name] = div
        $('[data-id="'+data.id+'"] #'+sanitised).attr('class', 'merge ' + @getStatusCss(component.status))
        $('[data-id="'+data.id+'"] #'+sanitised+' i').attr('class', @getFaIcon(component.status))
      else
        $('[data-id="'+data.id+'"] #'+sanitised).replaceWith div

      if data.colCount is 1
        $('[data-id="'+data.id+'"] .job').addClass('small')

      if data.job_css
        $('[data-id="'+data.id+'"] .job').addClass(data.job_css)

  draw: (data) ->
    $(this).attr('data-id', data.id)

    $('[data-id="'+data.id+'"] .col').empty()

    if data.colCount is 1
      for component in data.components
        div = @createDiv(component)
        $('[data-id="'+data.id+'"] .col.left').append div
      $('[data-id="'+data.id+'"] .col.left').removeClass('left')
      $('[data-id="'+data.id+'"] .job').addClass('small')
    else
      for component, i in data.components
        div = @createDiv(component)
        if (i + 1) % 2 or data.colCount is 1
          $('[data-id="'+data.id+'"] .col.left').append div
        else
          $('[data-id="'+data.id+'"] .col.right').append div

  handleCurl: (data) ->
    if data.uncurl?
      if @cached_div[data.name]
        $('[data-id="'+data.id+'"] #'+data.name).replaceWith @cached_div[data.name]
        @cached_div[data.name] = ''
      return

    unless @cached_div[data.name]
      @cached_div[data.name] = $('[data-id="'+data.id+'"] #'+data.name).clone()

    $('[data-id="'+data.id+'"] #'+data.name)
      .addClass "merge"
      .append '<span class="runtime"></span>'

    @time_events[data.name] = moment()
    setInterval(@setTime, 500)

  setTime: =>
    for key, value of @time_events
      diff = moment().diff(value, 'seconds')
      switch
        when diff <= 60 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 's') + "s")
        when diff > 60 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 'm') + "m")
        when diff > 120 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 'm') + "ms")
        when diff > 3600 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 'h') + "hr")
        when diff > 7200 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 'h') + "hrs")
        when diff > 86400 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 'd') + "dy")
        when diff > 172800 then $('[data-id="'+data.id+'"] #'+key+" .runtime").text(moment().diff(value, 'd') + "dys")

  getStatusCss: (status) ->
    switch status
      when "red" then "red job"
      when "green" then "green job"
      when "blue" then "green job" # support for hudson 1.x where blue means green
      when "grey" then "grey job"
      when "yellow" then "yellow job"
      when "aborted" then ""
      else "blue job flashing"

  getFaIcon: (status) ->
    switch status
      when "red" then "fa fa-warning faa-flash animated"
      when "green" then "fa fa-check"
      when "blue" then "fa fa-check"
      when "grey" then "fa fa-moon-o"
      when "yellow" then "fa fa-warning faa-flash animated"
      when "aborted" then ""
      else "fa fa-gears fa-spin"

  createDiv: (component) ->
    faIcon = @getFaIcon(component.status)
    status = @getStatusCss(component.status)
    div = '<li id="'+@sanitiseId(component.name)+'" class="'+status+'"><i class="'+faIcon+'"></i> '+component.name
    if component.branch_name?
      div = div + '<span class="branch_name"> ('+component.branch_name+')</span>'
    div = div + '</li>'
    return div

  sanitiseId: (id) ->
    id = id.replace(/\./g, '')
    id = id.replace(/\ /g, '')
    return id.replace(/-/g,'')
