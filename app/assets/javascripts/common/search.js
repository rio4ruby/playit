
function init_wf() {
    console.log("calling watchfield");
    $("#q").watchfield({
	name : "wf1",
	delay : 400,
	changed : function(event,ui) {
            var url = $(this).closest('form').attr('action');
            var params = {q: $(this).val()};
            console.log(params)
            $.get(url,params,function(data,textStatus) {
                console.log("wf changed status=" + textStatus + " url=" + url);
                $('#tab-search').html(data);
                bind_content_click();
                init_sr_hover();
                init_sr_links();
                wf_history(params);
            });
            //$('#q').closest('form').submit();
	}
    });
}
function init_wf_history() {
    var History = window.History; // Note: We are using a capital H instead of a lower h
    if ( !History.enabled ) {
         // History.js is disabled for this browser.
         // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }

    // Bind to StateChange Event
    History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        console.log("bind statechange");
        History.log(State.data, State.title, State.url);
    });
}


function wf_history(params) {
    
    var History = window.History; // Note: We are using a capital H instead of a lower h
    if ( !History.enabled ) {
         // History.js is disabled for this browser.
         // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }

    // Change our States

    params.q = params.q.replace(/\s/g,'+');
    var url = "?q=" + params.q;
    console.log("wf_history url=" + url);
    History.replaceState(params, "Player", url); // 
}

function wf_history0() {
    
    var History = window.History; // Note: We are using a capital H instead of a lower h
    if ( !History.enabled ) {
         // History.js is disabled for this browser.
         // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }

    // Bind to StateChange Event
    History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        History.log(State.data, State.title, State.url);
    });

    // Change our States
    History.pushState({state:1}, "State 1", "?state=1"); // logs {state:1}, "State 1", "?state=1"
    History.pushState({state:2}, "State 2", "?state=2"); // logs {state:2}, "State 2", "?state=2"
    History.replaceState({state:3}, "State 3", "?state=3"); // logs {state:3}, "State 3", "?state=3"
    History.pushState(null, null, "?state=4"); // logs {}, '', "?state=4"
    History.back(); // logs {state:3}, "State 3", "?state=3"
    History.back(); // logs {state:1}, "State 1", "?state=1"
    History.back(); // logs {}, "Home Page", "?"
    History.go(2); // logs {state:3}, "State 3", "?state=3"
}

function init_sr_hover() {
    $('#main').watchhover({
        delay: 500,
        action: function(event,ui) {
            var data = {
                q: $('#q').val(),
                el_id: ui.el.closest('[id|="sr"]').attr('id')
            };

            var url = '/home/aside';
            var fudge = 8;
            $('.hit-aside').load(url,data,function() {
                init_aside_links();
                bind_content_click();
                // var offset = $('#sidebar').offset();
                // var margLeft = $('#sidebar').css('margin-left') || "0";
                // var mleft = parseInt(margLeft);
                // var offleft = offset.left - mleft - fudge;
                
                // var fxtop = $('body > .navbar-fixed-top').height();
                // var scrollTop = $(window).scrollTop(); // check the visible top of the browser  
                // var winh = $(window).height();
                // var sidh = $('#sidebar').outerHeight(true);
                // console.log("sidh=" + sidh + " winh=" + winh + " fxtop=" + fxtop);
                // if( sidh > (winh - fxtop) ) {
                //     $('#sidebar').removeAttr("style");
                // }
                // else if  ((offset.top)<(scrollTop+fxtop)) {
                //     $('#sidebar').attr("style","position:fixed;top:" + fxtop + "px;left:" + offleft + "px;");
                // }
                
                // if ((offset.top)<(scrollTop+fxtop)) {
                //     $('#sidebar').attr("style","position:fixed;top:" + fxtop + "px;left:" + offleft + "px;");
                // }
                // else {
                //     $('#sidebar').removeAttr("style");
                // }
                
            });
        }
    });
}
function bind_content_click() {
    $('.link-name').off('click.content').on('click.content', function() {
        console.log("link-name: " + $(this).text() + " q:" + $('#q').val() );
        $('#q').val($(this).text()).closest('form').submit();
        return false;
    });
}
function bind_clear_form_click() {
    $('.search-form-wrapper i').on('click', function() {
        console.log("search-form i: " + $(this).text() + " q:" + $('#q').val() );
        $('#q').val("").focus();
        return false;
    });
}

function bind_scroll_aside(fudge) {
    var offset = $('#sidebar').offset();
    console.log(offset);

    if( offset ) {
        $(window).on('scroll.aside',function () {  
            var offset = $('#sidebar').offset();
            console.log(offset);
            var margLeft = $('#sidebar').css('margin-left') || "0";
            var mleft = parseInt(margLeft);
            var offleft = offset.left - mleft - fudge;
            var fxtop = $('body > .navbar-fixed-top').height();
            var scrollTop = $(window).scrollTop(); // check the visible top of the browser  
            var winh = $(window).height();
            var sidh = $('#sidebar').outerHeight(true);
            
            console.log("sidh=" + sidh + " winh=" + winh + " fxtop=" + fxtop);
            if( sidh > (winh - fxtop) ) {
                return;
            }
            console.log("margLeft=" + margLeft + " mleft=" + mleft + " offleft=" + offleft);
            console.log(offset);
            if ((offset.top)<(scrollTop+fxtop)) {
                $('#sidebar').attr("style","position:fixed;top:" + fxtop + "px;left:" + offleft + "px;");
            }
            else {
                $('#sidebar').removeAttr("style");
            }
        });
    }
}

function init_sr_scroll() {

    $(window).resize(function() {
        $(window).off('scroll.aside');
        
        //bind_scroll_aside(0);
    });
    
    //bind_scroll_aside(0);
 
}
function init_aside_links() {
    //console.log("INIT_ASIDE_LINKS");
    $('#main').find('.hit-aside')
        .find('.elem')
        .find('.elem-image,.image')
        .find('img')
        .click(function() {
            console.log("aside-link CLICK");
            var elem = $(this).closest(".elem");
            var plid = elem.closest('.playable').attr('id');
            var tempid = plid.replace(/^sr-/,'pl-');
            var dest_list = $('#playing-playlist').find('.listnode-content').first();
            var wc = elem.closest('.playable').attr('class');
            console.log("clicked sr link id=" + elem.attr('id') + " wc=" + wc);
            var wrapper = $('<div></div>').addClass('listnode-elem listnode-temp depth1')
                .addClass(wc).removeClass('hit-row')
                .attr('id',tempid)
                .html('<div class="listnode-header"></div>');
            var temp_elem = elem.clone().wrapAll(wrapper).parent().parent();
            dest_list.append(temp_elem);
        });
}
function init_sr_links() {
    console.log("INIT_SR_LINKS");
    $('#main').find('.hits')
        .find('.playable')
        .find('.elem-image,.image')
        .find('img')
        .click(function() {
            var elem = $(this).closest(".elem");
            var plid = elem.closest('.playable').attr('id');
            var tempid = plid.replace(/^sr-/,'pl-');
            var dest_list = $('#playing-playlist').find('.listnode-content').first();
            var wc = elem.closest('.playable').attr('class');
            console.log("clicked sr link id=" + elem.attr('id') + " wc='" + wc + "' dest_list=" + dest_list);
            var wrapper = $('<div></div>').addClass('listnode-elem listnode-temp depth1')
                .addClass(wc).removeClass('hit-row')
                .attr('id',tempid)
                .html('<div class="listnode-header"></div>');
            var temp_elem = elem.clone().wrapAll(wrapper).parent().parent();
            dest_list.append(temp_elem);
        });
}
function init_dragdrop_links() {
    console.log("INIT_DRAGDROP_LINKS");
    $('#playing-playlist').addClass('black');
    $('#left-side').droppable({
	hoverClass: "drop-highlight",
	tolerance: 'touch',
	accept: '.playable',
	revert: true,
	drop: function( event, ui) {
            console.log("DO DROP");
	}
    });
    $('#main').find('.hits').find('.playable').draggable({
	revert: true,
	disabled: false,
        start: function(event,ui) {
            //console.log("draggable.start: " + $(this).attr('id'));
            ui.helper.width(300);
            ui.helper.addClass('ui-corner-all');
	},
        delay: 500,
        helper: 'clone',
        appendTo: '#playlists',
	containment: 'parent',
	appendTo: 'body',
	opacity: 0.99
    }).disableSelection();
}
function init_history() {

}

$(document).ready(function() {
    init_wf();
    $('#search-options1 .btn').button();
    $('#search-options2 .btn').button();
    init_sr_hover();
    init_sr_links();
    init_sr_scroll();
    bind_content_click();
    bind_clear_form_click();
    console.log("READY 8");
    init_wf_history();
    //init_dragdrop_links();
});



function init_sr_scroll0() {
   $(window).scroll(function(event) {
        console.log("scroll scrollTop=" + $(this).scrollTop());
    });
    $gridColumns =            9;
    $gridColumnWidth =        60;
    $gridGutterWidth =        20;
    $gridRowWidth =           $gridColumns * $gridColumnWidth + $gridGutterWidth * ($gridColumns - 1);
    console.log("gridRowWidth=" + $gridRowWidth);
    // check where the shoppingcart-div is  
    var offset = $('#sidebar').offset();
    var pad = $(document).width() - $(window).width();
    console.log(offset);
    console.log("pad=" + pad + " body.width=" + $('body').width() + " doc.width=" + $(document).width() +
                " win.width=" + $(window).width());
    var margLeft = $('#sidebar').css('margin-left');
    var mleft = parseInt(margLeft);
    console.log("margLeft=" + margLeft + " mleft=" + mleft);
    var offleft = offset.left - mleft - 8;
    var prevtop = 0;
    $(window).scroll(function () {  
        var scrollTop = $(window).scrollTop(); // check the visible top of the browser  
        var winh = $(window).height();
        var doch = $(document).height();
        var bodh = $('body').height();
        var sidh = $('#sidebar').outerHeight(true);
        console.log("winh=" + winh + " doch=" + doch + " bodh=" + bodh + " sidh=" + sidh);
        var sidoff = $('#sidebar').offset();
        var sidbot = sidoff.top + sidh;
        var bdiff = winh - sidbot + scrollTop;
        var tdiff =  sidoff.top - scrollTop - 40;
        console.log("bdiff=" + bdiff + " tdiff=" + tdiff + " sidbot=" + sidbot + "sidtop=" + sidoff.top);
        var tophidden = scrollTop;
        var bothidden = doch - scrollTop - winh;
        var topdiff = scrollTop - prevtop
        var sbhidden = sidh - winh + 40;
        console.log("tophidden=" + tophidden + " bothidden=" + bothidden + " topdiff=" + topdiff + " sbhidden=" + sbhidden);

        var sbtop = scrollTop + sidh;
        var topofwin = scrollTop + winh;
        var winsbdiff = sbtop - topofwin;
        console.log("sbtop=" + sbtop + " topofwin=" + topofwin + " winsbdiff=" + winsbdiff);
        prevtop = scrollTop;
        var fxtop = 40;
        console.log("fxtop="+fxtop + " cmp:" + (offset.top) + ' < ' + (scrollTop+fxtop));

        if( sidh > winh ) {
            return;
        }
        
        if ((offset.top)<(scrollTop+fxtop)) {
            $('#sidebar').attr("style","position:fixed;top:" + fxtop + "px;left:" + offleft + "px;");
        }
        else {
            $('#sidebar').removeAttr("style");
        }

        // if ((offset.top-40)<scrollTop) {
        //     $('#sidebar').attr("style","position:fixed;top:" + 40 + "px;left:" + offleft + "px;");
        // }
        // else {
        //     $('#sidebar').removeAttr("style");
        // }




        
        // if( bdiff > 0 && tdiff >= 0 ) {
        //    $('#sidebar').removeAttr("style");
        // }
        // else if( tdiff < 0 && bdiff >=0 ) {
        //     $('#sidebar').attr("style","position:fixed;top:" + 40 + "px;left:" + offleft + "px;");

            
        // }
        // else if( tdiff < 0 && bdiff < 0 ) {
        //     var csspos = $('#sidebar').css('position');
        //     if( csspos != 'absolute') {
        //         var sidoff = $('#sidebar').offset();
        //         var stop = sidoff.top + 40;
        //         $('#sidebar').attr("style","position:absolute;top:" + stop + "px;left:" + offleft + "px;");
        //     }
        // }
        // else if( tdiff < 0 && bdiff >=0 ) {
        //     $('#sidebar').attr("style","position:fixed;top:" + 40 + "px;left:" + offleft + "px;");

            
        // }
 
        // }
        // if ((offset.top-40)<scrollTop) {
        // }
        // else {
        //     $('#sidebar').removeAttr("style");
        // }
    });  

}
