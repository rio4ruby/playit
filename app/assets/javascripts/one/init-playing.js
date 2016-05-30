console.log("init-playing.js init-playing.js init-playing.js init-playing.js ");
function init_nodeplayer() {
    console.log("init_nodeplayer");
    $('#the-player').smplayer({
        sm2ready: function() {
            console.log("#the-player: sm2ready()");
            $.event.trigger('sm2ready');
            $('#play-progress').playprogress({
                max: 10000,
                value: 3000
            });
            // $('.player-position-slider').playslider({
            //     max: 100,
            //     value: 48
            // });
            $('#player-carousel').nodeplayer({
                trackselected: function(event,ui) {
                    console.log("TRACK SELECTED: id=" + ui.sound_info.sound_id + " artist='" + ui.sound_info.artist + "'");
                },
                finish: function(event,ui) {
                    //var href = $('.player-button-next .player-link').attr('href');
                    //load_bottom(href,{ doplay: true });
                    //$.get(href,{doplay:true});
                    //$.event.trigger('playcontrol');
                }
            });
            $('#player-carousel').playcarousel();
            
        }
        
    });
}
function init_playing() {
    console.log("init_playing()");
    $('.playbutton').playbutton();

    $('.playbutton').parent().on('click',function(event) {
        console.log(".overlay CLICK");
        $(this).children('.playbutton').click();
        return false;
    });

    $('.prevbutton').click(function() {
        console.log('.prevbutton CLICK');
        $.event.trigger('prevcontrol');
    });
    $('.nextbutton').click(function() {
        console.log('.nextbutton CLICK');
        $.event.trigger('nextcontrol');
    });
       

}
function init_playing_playlist() {
    console.log("init_playing_playlist()");
    $('body').on('trackplayer', function(event,ui) {
        var si = ui.sound_info;
        if(si) {
            node_el_id = si.node_id;
            node_id = node_el_id.replace(/^.*-/,'');
            console.log("setting cookie active_id=" + node_id);
            $.cookie('active_id', node_id, { expires: 7, path: '/' });
        }
    });


    $('#playing-playlist').load('/list_nodes',function() {
        init_sortables();
        $(this).find('.listnode-header.depth1').live('click',function() {
	    $(this).next().toggle('fast');
	    return false;
        }).next().hide();
    });
    $('#playing-playlist').on('playlistchanged', function() {
        console.log("CAUGHT playlistchanged");
        
    });
    $('#playing-playlist').on('trackplayer', function(event,ui) {
        var si = ui.sound_info;
        if(si) {
            node_id = si.node_id;
            console.log("got trackplayer node_id = " + node_id);
            $('.AudioFile.playing').removeClass('playing');
            $('#' + node_id).addClass('playing');
        }
    });
    
    
}
function init_sortables() {
    $('.ListHead.listnode-content').sortable({
        create: function(event, ui) {
            console.log('.ListHead.listnode-content sortable created');
        },
        update: update_cb,
        items: '> .listnode-elem',
        axis: 'y',
        //containment: 'parent',
        forcePlaceholderSize: true,
        placeholder: 'listnode-sortable-placeholder',
        delay: 500
        
        
    }).disableSelection();
    $('.Album.listnode-content').sortable({
        create: function(event, ui) {
            console.log('.Album.listnode-content sortable created');
        },
        update: update_cb,
        items: '> .listnode-elem',
        axis: 'y',
        //containment: 'parent',
        forcePlaceholderSize: true,
        placeholder: 'listnode-sortable-placeholder',
        connectWith: '.ListHead.listnode-content',
        delay: 500
        
    }).disableSelection();
}
function update_cb(event,ui) {
    console.log('.listnode-content sortable update');
    console.log('  item is: ' + ui.item.attr('id') + ' parent is: ' + ui.item.parent().closest('.listnode-elem').attr('id') + " index=" + ui.item.index());
    var data = {
        item: ui.item.attr('id'),
        list: ui.item.parent().closest('.listnode-elem').attr('id'),
        index: ui.item.index()
    };
    $.getJSON("/list_nodes/move_to",data);
    
}


function init_quo() {
    // $$("#hammer-area").tap(function(ev) {
    //     console.log(ev);
    //     $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
    // });
    $$("#hammer-area").hold(function(ev) {
        console.log(ev.type);
        $('#hammer-msgs').append('<div>' + "quo: " + ev.type + '</div>');
    });
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
}

function init_hammer() {
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

    $("#hammer-area")
        .hammer({ drag_max_touches:0})
        .on(all_events.join(" "), function(ev) {
            var ndevents = all_events.filter(function(element,index,array) {
                return true;
                //return element.slice(0,4) !== 'drag';
            });
            if( hammer_events.indexOf(ev.type) >= 0 ) {
                console.log(ev.type);
                $('#hammer-msgs').append('<div>' + "hammer: " + ev.type + " " + ev.gesture.deltaTime + " " + ev.gesture.deltaX + " " + ev.gesture.deltaY + '</div>');
            }
            var touches = ev.gesture.touches;
            ev.gesture.preventDefault();
            
            for(var t=0,len=touches.length; t<len; t++) {
                var target = $(touches[t].target);
                console.log("left:" + touches[t].pageX + " top:" + touches[t].pageY);
            //     target.css({
            //         zIndex: 1337,
            //         left: touches[t].pageX-50,
            //         top: touches[t].pageY-50
            //     });
            }

            // for(var t=0,len=touches.length; t<len; t++) {
            //     var target = $(touches[t].target);
            //     target.css({
            //         zIndex: 1337,
            //         left: touches[t].pageX-50,
            //         top: touches[t].pageY-50
            //     });
            // }
        });
}


function setup_touchy() {
    console.log("INIT_TOUCHY");
    var all_events = ["touchy-longpress","touchy-drag","touchy-pinch",
                      "touchy-rotate","touchy-swipe" ];
    //$('#hammer-area').on(all_events.join(' '), function(event,phase,$target,data) {
    $('#hammer-area').on('touchy-drag', function(event) {
        console.log(ev);
        $('#hammer-msgs').append('<div>' + "touchy: " + ev.type + '</div>');
    });
}

var init_playing_complete;
$(document).ready(function() {
    console.log("DOCUMENT READY!!!!!!!");
    if(!init_playing_complete) {
        init_playing_complete = true;
        console.log("About to setup touchy");
        //setup_touchy();
        init_playing();
        init_playing_playlist();
        init_nodeplayer();
        //init_quo();
        init_hammer();
        $('#hammer-area').touch({
            tap: function(event) {
                console.log("touch: tap");
            },
            hold: function(event) {
                console.log("touch: hold");
            },
            swipe: function(event) {
                console.log("touch: swipe");
            }
            
        });
    }
});
