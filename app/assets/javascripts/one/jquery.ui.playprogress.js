(function($){
    
    $.widget("ui.playprogress", {
	options: {
        },
        
	_create: function(){
            $ps = this;
            this._sliding = false;
            this._max = 0;
            this._secs = 0;
            this._priorsecs = 0;
            this._slidesecs = 0;
            
	    // by default, not playing.
            this.element.progress({
                range: 'min',
                start: function(event,ui) {
                    var max = $ps.element.progress("option","max");
                    console.log("progress START ui.value=" + ui.value + " interval_id=" + $ps._interval_id, " max=" + max);
                    $ps._restart_interval = ($ps._interval_id != null);
                    $ps._sliding = true;
                    $ps._slidesecs = $ps._secs;
                    $ps._interval_clear();
                },
                stop: function(event,ui) {
                    var max = $ps.element.progress("option","max");
                    console.log("progress STOP ui.value=" + ui.value + " interval_id=" + $ps._interval_id), " max=" + max;
                    $.event.trigger('positioncontrol',ui);
                    $ps._sliding = false;
                    if( $ps._restart_interval ) {
                        $ps._interval_start();
                    }
                },
                slide: function(event,ui) {
                    var secs = Math.floor(ui.value/1000);
                    if( $ps._slidesecs != secs ) {
                        $ps._slidesecs = secs;
                        $('.player-time-played').html(ms2str(ui.value));
                        $('.player-time-remaining').html(ms2str($ps._max - ui.value));
                    }
                },
                change: function(event,ui) {
                    var max = $ps._max;
                    if( ui.value ) {
                        $ps._secs = Math.floor(ui.value/1000);
                        if( $ps._secs != $ps._priorsecs ) {
                            $ps._priorsecs = $ps._secs;
                            $('.player-time-played').html(ms2str(ui.value));
                            console.log("change max=" + max + " val=" + ui.value + " max-val=" + (max - ui.value) + " ms2str=" + ms2str(max - ui.value));
                            $('.player-time-remaining').html(ms2str(max - ui.value));
                        }
                    }
                }
            });

            this._bind_events();
            
	    // remember this instance
	    $.ui.playprogress.instances.push(this.element);
	},
        reset: function(si) {
            this._sliding = false;
            this._max = si.duration;
            this._secs = 0;
            this._priorsecs = 0;
            $('.player-time-remaining').html(ms2str(si.duration));
            $('.player-time-played').html(ms2str(0));
            this.element.progress('option','max',si.duration);
            this.element.progress('option','value',0);
        },
        max: function(v) {
            this._max = v;
            this.element.progress('option','max',v);
        },
        value: function(v) {
            if( !this._sliding && (typeof v != "undefined") ) {
                this.element.progress('value',v);
            }
            return this.element.progress('value');
        },
        _interval_clear: function() {
            clearInterval(this._interval_id);
            this._interval_id = null;
        },
        _pos: 0,
        _interval_handler: function(start,inc) {
            var $ps = this;
            var counter = 120;
            this._pos = start;
            var intervalHandler = function(event) {
                $ps._pos += inc;
                $ps.element.progress("value",$ps._pos);
                //console.log("interval: " + counter + " " + $ps._pos);
                if( --counter <= 0 ) {
                    $ps._interval_clear();
                }
            };
            return intervalHandler;
        },
        _interval_start: function(pos) {
            if(!pos) {
                pos = this.element.progress("value");
            }
            var inc = 200;
            var intervalHandler = this._interval_handler(pos,inc);
            this._interval_id = setInterval(intervalHandler,inc);
        },
        
        _bind_events: function() {
            var $ps = this;
            var $el = this.element;
            this.element.bind('durationplayer',function(event,ui) {
                $el.progress('option','max',ui.max);
                $ps._max = ui.max;
            });
            this.element.bind('pauseplayer',function(event,ui) {
                $ps._interval_clear();
            });
            this.element.bind('stopplayer',function(event,ui) {
                $ps._interval_clear();
            });
            this.element.bind('trackplayer',function(event,ui) {
                $ps.reset(ui.sound_info);
            });
            this.element.bind('positionplayer',function(event,ui) {
                if( !$ps._sliding ) {
                    console.log('playprogress: positionplayer value=' + ui.value + " _pos=" + $ps._pos + " interval_id=" + $ps._interval_id);
                    $ps._interval_clear();
                    $el.progress('value',ui.value);
                    $ps._interval_start(ui.value);
                }
            });
        },
	_init: function(){
	},
        
	destroy: function(){
	    // remove this instance from $.ui.playprogress.instances
	    var element = this.element,
	    position = $.inArray(element, $.ui.playprogress.instances);
            
	    // if this instance was found, splice it off
	    if(position > -1){
		$.ui.playprogress.instances.splice(position, 1);
	    }
            
	    // call the original destroy method since we overwrote it
	    $.Widget.prototype.destroy.call( this );
	},
        
	_getOtherInstances: function(){
	    var element = this.element;
            
	    return $.grep($.ui.playprogress.instances, function(el){
		return el !== element;
	    });
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
    
    $.extend($.ui.playprogress, {
	instances: []
    });
    
})(jQuery);
