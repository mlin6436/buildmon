# dashing.js is located in the dashing framework
# It includes jquery & batman for you.
#= require dashing.js

#= require_directory .
#= require_tree ../../widgets

console.log("Yeah! The dashboard has started!")

# target browser resolution
x_resolution = 1920
y_resolution = 1080

# gridster margin as defined in application.scss (.gridster class) 
gridster_margin = 5

# margins to use around each widget
x_margin = 5
y_margin = 5

# define fixed number of rows and columns
num_cols = 12
num_rows = 12

# inner margin size will be the right margin of the widget plus the left margin of it's adjacent widget
x_inner_margin = x_margin * 2
y_inner_margin = y_margin * 2

# consider margins on the gridster container and multiple by 2 for left and right
x_outer_margins = (x_margin + gridster_margin) * 2
y_outer_margins = (y_margin + gridster_margin) * 2

x_total_inner_margins = (num_cols - 1) * x_inner_margin
y_total_inner_margins = (num_rows - 1) * y_inner_margin
 
widget_width = (x_resolution - x_outer_margins - x_total_inner_margins) / num_cols
widget_height = (y_resolution - y_outer_margins - y_total_inner_margins) / num_rows

Dashing.on 'ready', ->
  Dashing.widget_margins ||= [x_margin, y_margin]
  Dashing.widget_base_dimensions ||= [widget_width, widget_height]
  Dashing.numColumns ||= num_cols
  Dashing.numRows ||= num_rows

  Batman.setImmediate ->
    $('.gridster').width(x_resolution)
    $('.gridster ul:first').gridster
      widget_margins: Dashing.widget_margins
      widget_base_dimensions: Dashing.widget_base_dimensions
      avoid_overlapped_widgets: !Dashing.customGridsterLayout
      max_size_x: num_cols
      draggable:
        stop: Dashing.showGridsterInstructions
        start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()
