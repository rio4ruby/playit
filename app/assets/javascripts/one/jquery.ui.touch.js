(function($){
    
    $.widget("ui.touch", {
	options: {
            events: [],
            tap: null,
            hold: null,
            swipe: null,
            swipeleft: null,
            swiperight: null,
            swipeup: null,
            swipedown: null
        },
        
	_create: function(){
            console.log("touch:_create");
	},
	_init: function(){
            console.log("touch:_init");
            this._init_quo();
            this._init_hammer();

	},
        _init_quo: function() {
            // $$("#hammer-area").tap(function(ev) {
            //     console.log(ev);
            //     $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
            // });
            if( this.options['hold'] ) {
                $$($(this).get()).hold(function(ev) {
                    console.log(ev.type);
                    $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
                });
            }
            // $$("#hammer-area").swipeLeft(function(ev) {
            //     console.log(ev);
            //     $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
            // });
            // $$("#hammer-area").swipeDown(function(ev) {
            //     console.log(ev);
            //     $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
            // });
            // $$("#hammer-area").swipeRight(function(ev) {
            //     console.log(ev);
            //     $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
            // });
            // $$("#hammer-area").swipeUp(function(ev) {
            //     console.log(ev);
            //     $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
            // });
        },
        _prev_dx: 0,
        _prev: {
            tap: { deltaTime: 0 }
        },
        _prevDeltaTime: {
            tap: 0,
            drag: 0,
            dragleft: 0,
            dragright: 0
        },
        _handle_event: function(ev) {
            var drag_events = ["dragstart", "drag", "dragend", "dragleft", "dragright",
                              "dragup", "dragdown"];
            $this = this;
            $('#hammer-msgs').append('<div>' + "hammer: " + ev.type + " " + ev.gesture.deltaTime + " " + ev.gesture.deltaX + " " + ev.gesture.deltaY + '</div>');

            //console.log(ev.type + ": " + drag_events.indexOf(ev.type));
            if( $this._prevDeltaTime[ev.type] != ev.gesture.deltaTime ) {
                console.log("HAMMER: " + ev.type + " " + ev.gesture.deltaTime + " " + ev.gesture.deltaX + " " + ev.gesture.deltaY );
                switch(ev.type) {
                case 'tap' :
                    $this._trigger(ev.type,ev);
                    break;
                case 'drag' :
                    break;
                case 'dragleft' :
                    if( $this._prev_dx != ev.gesture.deltaX) {
                        $this._trigger(ev.type,ev);
                        $this._prev_dx = ev.gesture.deltaX;
                    }
                    break;
                case 'dragright' :
                    if( $this._prev_dx != ev.gesture.deltaX) {
                        $this._trigger(ev.type,ev);
                        $this._prev_dx = ev.gesture.deltaX;
                    }
                    break;
                default:
                    $this._trigger(ev.type,ev);
                    break;
                }
                $this._prevDeltaTime[ev.type] = ev.gesture.deltaTime;
            }
            else {
                console.log("SKIP HAMMER: " + ev.type + " " + ev.gesture.deltaTime + " " + ev.gesture.deltaX + " " + ev.gesture.deltaY );

            }

            // if(drag_events.indexOf(ev.type) >= 0) {
            //     //console.log(ev.type + ": " + $this._prev_dx + " , " + ev.gesture.deltaX);
            //     if( $this._prev_dx != ev.gesture.deltaX) {
            //         $this._trigger(ev.type,ev);
            //         $this._prev_dx = ev.gesture.deltaX;
            //     }
            // }
            // else {
            //     $this._trigger(ev.type,ev);
            // }
        },
        _handler: {
            tap: function(event) {
            },
            drag: function(event) {
            },
            dragleft: function(event) {
            },
            dragright: function(event) {
            },
        },
        _init_hammer: function() {
            var all_events = ["touch", "release", "hold", "tap", "doubletap",
                              "dragstart", "drag", "dragend", "dragleft", "dragright",
                              "dragup", "dragdown", "swipe", "swipeleft", "swiperight",
                              "swipeup", "swipedown", "transformstart", "transform",
                              "transformend", "rotate", "pinch", "pinchin", "pinchout"];
            
            var sans_drag_events = ["touch", "release", "hold", "tap", "doubletap",
                                    "swipe", "swipeleft", "swiperight",
                                    "swipeup", "swipedown", "transformstart", "transform",
                                    "transformend", "rotate", "pinch", "pinchin", "pinchout"];
            
            var some_events = ["touch","release", "hold", "tap","swipe", "swipeleft", "swiperight",
                               "swipeup", "swipedown", "pinch", "pinchin", "pinchout"];
            
            var hammer_events = ["tap","swipe", "swipeleft", "swiperight",
                                 "swipeup", "swipedown"];
            var $this = this;
            $(this.element)
                .hammer({ drag_max_touches:0})
                .on(all_events.join(" "), function(ev) {
                    if( $this.options[ev.type] ) {
                        $this._handle_event(ev);
                    }
                    // var touches = ev.gesture.touches;
                    ev.gesture.preventDefault();
                    
                    // for(var t=0,len=touches.length; t<len; t++) {
                    //     var target = $(touches[t].target);
                    //     target.css({
                    //         zIndex: 1337,
                    //         left: touches[t].pageX-50,
                    //         top: touches[t].pageY-50
                    //     });
                    // }
                });
        },
        
        _bind_events: function() {
            //console.log("touch: bind_events");
            this._init_quo();
            this._init_hammer();
        },
        
        
	destroy: function(){
            console.log("touch:destroy");
	    // call the original destroy method since we overwrote it
	    $.Widget.prototype.destroy.call( this );
	},
        
        
	_setOption: function(key, value){
	    this.options[key] = value;
            
	    switch(key){
	    case "something":
		// perform some additional logic if just setting the new
		// value in this.options is not enough. 
		break;
	    }
	}
    });
    
    $.extend($.ui.touch, {
	instances: []
    });
    
})(jQuery);
