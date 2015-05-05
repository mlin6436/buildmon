var singleTimerController =(function(){
  var tick = 500,
  starttime = 0,
  curms = 0,
  widgets = [];

  var init = function(){
    starttime = getTime();
    setTimeout(onTick, tick);
  };

  var getTime = function(){
    return new Date().getTime();
  };

  var registerWidget= function(w, cb){
    widgets.push({ widget:w, callback:cb });
  };

	var getWidgets= function(){
		return widgets;
	};

  var onTick = function(){
    var self = this;
    curms = getTime();
    widgets.forEach(function(e,i){
      e.callback(curms);
    });
    setTimeout(onTick, tick);
  };

	init();
  return {
    registerWidget: registerWidget,
		getWidgets: getWidgets
  };
})();
