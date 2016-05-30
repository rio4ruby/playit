(function($){
    
    $.widget("ui.progress", {
	options: {
            max: 100,
            value: 88,
            min: 0,
            step: 1, 
            
            change: null,
            slide: null,
            start: null,
            stop: null
            
        },
        
	_create: function(){
            console.log("progress._create");
            var $this = this;
            //this.element.addClass('progress').html($('<div></div>').addClass('bar bar-info'));
            //$('<div></div>').addClass('bar bar-warning').appendTo(this.element);
	},
	_init: function(){
            console.log("progress._init");
            this._bind_events();
            this._setOption("value",90);
	},
        reset: function(si) {
        },
        max: function(v) {
        },
        _interval_clear: function() {
        },
        _pos: 0,
        _interval_handler: function(start,inc) {
        },
        
        _handle_drag: function(event) {
            var $this = this
            return function(event) {
                console.log(event.type + ": " + event.gesture.deltaX);
                if(event.gesture.deltaX != 0) {
                    $this._setOption('pos',$this._drag_pos + event.gesture.deltaX);
                    $this._trigger('slide', event,{ value: $this.options.value });
                }
            };
          },
        _drag_pos: 0,
        _bind_events: function() {
            var $this = this;
            var progel = this.element.children('.prog');
            this.element.touch({
                drag: $this._handle_drag(),
                dragstart: function(event) {
                    console.log("dragstart width=" + progel.width());
                    progel.addClass('noTransition')
                    $this._drag_pos = progel.width()+$this.element.offset().left;
                    $this._trigger('start', event,{ value: $this.options.value });
                },
                dragend: function(event) {
                    console.log("dragend width=" + progel.width());
                    progel.removeClass('noTransition')
                    $this._drag_pos = progel.width();
                    $this._trigger('stop', event,{ value: $this.options.value });
                    $this._trigger('change', event,{ value: $this.options.value });
                },
                //dragleft: $this._handle_drag(),
                //dragright: $this._handle_drag()
            });
            this.element.first().touch({
                tap: function(event) {
                    console.log("progress#touch: " + event.type);
                    var touches = event.gesture.touches;
                    event.gesture.preventDefault();
                    for(var t=0,len=touches.length; t<len; t++) {
                        $this._setOption("pos",touches[t].pageX);
                        $this._trigger('change', event,{ value: $this.options.value });
                        // var left = $this.element.offset().left;
                        // console.log("left=" + left);
                        // var pos = touches[t].pageX - left;
                        // var width = $this.element.width();
                        // $this.options.value = $this.options.max * (pos/width);
                        // var pct = ($this.options.value/$this.options.max) * 100
                        // $this._setWidth();
                        // console.log("left=" + left + " pos=" + pos + " width=" + width + " pct=" + pct);
                        //console.log("left:" + touches[t].pageX + " top:" + touches[t].pageY);
                    }
                }
            });
        },
        
	destroy: function(){
	    // remove this instance from $.ui.progress.instances
	    var element = this.element,
	    position = $.inArray(element, $.ui.progress.instances);
            
	    // if this instance was found, splice it off
	    if(position > -1){
		$.ui.progress.instances.splice(position, 1);
	    }
            
	    // call the original destroy method since we overwrote it
	    $.Widget.prototype.destroy.call( this );
	},
        value: function(v) {
            if( arguments.length > 0 ) {
                this._setOption('value',v);
            }
            return this.options.value;
        },
        _setPct: function(pct) {
            this.element.children('.prog').width((pct*100).toString() + '%');
        },
        _pos2val: function(pos) {
            var pct = (pos-this.element.offset().left)/this.element.width();
            return (this.options.max - this.options.min) * pct;
        },
	_setOption: function(key, value) {
	    this.options[key] = value;
            
	    switch(key){
	    case "value":
                var pct = value/(this.options.max-this.options.min);
                this._setPct(pct);
                this._trigger('change',this.options.value);
		break;
            case "pos":
                this.options.value = this._pos2val(value);
                this.element.children('.prog').width(value-this.element.offset().left);
                this._trigger('change',this.options.value);
                break;
	    }
	}
    });
    
    $.extend($.ui.progress, {
	instances: []
    });
    
})(jQuery);
