class Dashing.Buildblamer extends Dashing.Widget

  ready: ->
    setInterval(@rotateCulprits, 10000)
    
  onData: (data) ->
    @count = 0 if not @count?
    @set 'builds', data.builds

  rotateCulprits: =>
    broken_build  = @get('builds')[@count % @get('builds').length]
    id            = @get('id')
    width         = $("[data-id = "+id+"].widget").css("width")
    image_width   = Math.floor ( (1/2) * parseInt ( width ) )

    if broken_build.brokenAt?
      timestamp = "Broken at " + moment(parseInt broken_build.brokenAt).format("HH:mm")
    else
      timestamp = "Last updated at " + moment(@get('updatedAt') * 1000).format("HH:mm")
    
    if broken_build.name isnt $("[data-id = "+id+"] .first .title").text()
      $("[data-id = "+id+"].widget").append @createContainer broken_build, image_width, timestamp
      $("[data-id = "+id+"] .gravatar")
        .css "width", image_width
        .css "height", image_width
      $("[data-id = "+id+"] .container.second")
        .css "left", width
        
      color = if broken_build.name then "#ed4337" else "#38c143"
      $("[data-id = "+id+"].widget").animate({backgroundColor: color}, 5000)
      $("[data-id = "+id+"] .container.first").animate({left: "-"+width}, 5000)
      $("[data-id = "+id+"] .container.second").animate({left: 0}, 5000)

      callback = ->
        $("[data-id = "+id+"] .container.first").remove()
        $("[data-id = "+id+"] .container.second").attr("class", "container first")
      setTimeout callback, 5000

    @count++

  createContainer: (build, image_width, timestamp) ->
    '<div class="container second">	
    	<span class="align-helper"></span>
    	<img class="gravatar" src="'+build.image_url+'"/>
    	<h1 class="title" data-bind="name">'+build.name+'</h1>
    	<p class="more-info" data-bind="committer">'+build.committer+'</p>
    	<p class="updated-at" data-bind="updatedAtMessage">'+timestamp+'</p>
    </div> '
