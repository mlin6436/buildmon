class Dashing.Charting extends Dashing.Widget

  ready: ->
    widget = $('#'+this.get('id'))
    widget.find('.canvas').attr("width", parseInt($(@node).css("width")) - 10)
    widget.find('.canvas').attr("height", parseInt($(@node).css("height")) + (parseInt($(@node).css("height")) * 0.05))
    widget.find('.canvas').css("margin-bottom", "-"+(parseInt($(@node).css("height")) * 0.08)+"px")
    widget.find('.canvas').css("margin-right", "-15px")
    
    canvas = document.getElementById(this.get('id')).getElementsByTagName("canvas")[0]

    ctx = canvas.getContext "2d"
    @myChart = new Chart(ctx)

  onData: (data) ->
    $(@node).css("background-color", data.color)

    chartOptions = {
      animation: false,
      scaleGridLineColor : "rgba(255,255,255,0)",
      scaleLineColor: "rgba(255,255,255,0.8)",
      scaleFontColor: "rgba(255,255,255,0.8)",
      datasetFill: true,
      pointDot: false,
      scaleBeginAtZero: true,
      pointHitDetectionRadius : 3,
    }
    
    @myChart.Line(@createChartData(data.dataSources), chartOptions) if @myChart? and data.chartType == "line"
    @myChart.Bar(@createChartData(data.dataSources), chartOptions) if @myChart? and data.chartType == "bar"
    @myChart.Radar(@createChartData(data.dataSources), chartOptions) if @myChart? and data.chartType == "radar"

  createChartData: (dataSources) ->
    dataSets = []
    
    for dataSource in dataSources
      labels = []
      dataPoints = []
      
      for key, value of dataSource.data
        labels.push key.split " ", 1
        dataPoints.push value

      dataSets.push {
        fillColor:"rgba("+dataSource.lineColor+",0.2)", 
        strokeColor: "rgba("+dataSource.lineColor+",0.6)",
        pointColor: "rgba("+dataSource.lineColor+",1)",
        pointStrokeColor: "rgba("+dataSource.lineColor+",1)",
        pointHighlightFill: "rgba("+dataSource.lineColor+",1)", 
        pointHighlightStroke: "rgba("+dataSource.lineColor+",0.8)",
        data: dataPoints
      }
      
    chartData = { labels: labels,  datasets: dataSets }

