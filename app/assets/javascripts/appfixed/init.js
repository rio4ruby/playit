var init_playing_complete;

function init_playing() {
    console.log("init_playing()");
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
function load_playlist() {
   $.ajax({
        url: '/list_nodes',
        statusCode: {
            422: function() {
                $('#playing-playlist').load("/users/sign_in",function() {
                    
                });;
            }
        }
    }).done(function(data,textStatus,jqXHR) {
        $('#playing-playlist').html(data).playlist();
    });

}
function loadwiki(data) {
    console.log('LOADWIKI: ');
    console.log(data);
    $('#wikiside').html('<h1>Hello</h1>' + '<p>' + data.wikiurl + '</p>');

    // var jqxhr = $.ajax({
    //     url: 'https://en.wikipedia.org/w/api.php',
    //     data: { action: 'query',
    //             titles: 'Go',
    //             prop: 'revisions',
    //             rvprop: 'content',
    //             format: 'json'
    //           },
    //     dataType: 'json',
    //     type: 'POST',
    //     headers: { 'Api-User-Agent': 'Example/1.0' }
    // }).done(function(data, textStatus, jqXHR) {
    //     // alert( "success" );
    // }).fail(function( jqXHR, textStatus, errorThrown) {
    //     // alert( "error: " + textStatus + " errorThrown: " + errorThrown);
    // });

    // var jqxhr = $.ajax({
    //     url: data.wikiurl,
    //     data: { action: 'render',
    //             title: 'The_Who'
    //           },
    //     type: 'GET',
    //     crossDomain: true
    // }).done(function(data, textStatus, jqXHR) {
    //     alert( "success" );
    // }).fail(function( jqXHR, textStatus, errorThrown) {
    //     alert( "error: " + textStatus + " errorThrown: " + errorThrown);
    // });





    //    $.get(data.wikiurl, function(dat) {
    //        $('#wikiside').html('<h1>Goodbye</h1>');
    //
    //    });
    // $.get(data.wikiurl, function(dat) {
    //     console.log("LOADED: " + data.wikiurl);
    //     var wikid = "wiki-" + data.wikiname;
    //     $('.wiki-artist').removeClass('wiki-artist-active');
    //     var vc = $(dat)
    //         .wrapAll('<div></div>')
    //         .parent()
    //         .find(".infobox.vcard")
    //         .wrapAll('<div class="wiki-artist wiki-artist-active" ' + "id=" + wikid + '></div>')
    //         .parent();
    //     console.log(vc);
    //     $('#wikiside').append(vc);
    //     $('#' + wikid).find('a').attr('target','_blank');
    // });
}
function load_playing_wiki() {
    console.log('load_playing_wiki');
    $.getJSON('/home/playing_wiki', function(data) {
        console.log(data);
        var wikiname = data.wikiname;
        var sel = "#wiki-" + wikiname;
        console.log(sel);
        console.log($(sel).length);
        if( $(sel).length == 0) {
            loadwiki(data);
        }
        else {
            $('.wiki-artist-active').removeClass('wiki-artist-active');
            $(sel).addClass('wiki-artist-active');
        }
    });
}
function init_tabs() {
    $(function () {
        $('#main-tabs a[href="#tab-search"]').tab('show'); // Select tab by name
    });
    $('#main-tabs').on('shown', function(event) {
        console.log('#main-tabs SHOWN id=' + $(event.target).attr('id') );
        if( $(event.target).attr('id') == 'tab-now-playing-link' ) {
            
            $('#wikiside').on('trackcontrol trackplayer', function(event) {
                console.log("#wikiside caught " + event.type);
            });
            $('#lyricside').off('trackplayer trackcontrol').on('trackplayer trackcontrol', function(event) {
                $.ajax({
                    url: '/home/playing_lyrics'
                }).done(function(data) {
                    $('#lyricside').html(data);
                    //load_playing_wiki();
                });
                // $('#lyricside').load('/home/playing_lyrics', function() {
                //     load_playing_wiki();
                // });
            });
        }
        else {
            $('#lyricside').off('trackplayer trackcontrol');

        }
    });
    $('#main-tabs').on('show', function(event) {
        console.log('#main-tabs show active-tab=' + o2s($(event.target)));
        if($(event.target).attr('id') == 'tab-now-playing-link') {
            var el = $('#playing-playlist .playing')
            //$('#wikiside').load('/w/index.php?action=render&title=The_Who');

            load_playing_wiki();
            $.ajax({
                url: '/home/playing_lyrics'
            }).done(function(data) {
                $('#lyricside').html(data);
            });
        }
        
    });
    $.ajax({
        url: '/home/playing_lyrics'
    }).done(function(data) {
        $('#lyricside').html(data);
    });
    
}

$(document).ready(function() {
    load_playlist();
    init_tabs();
    // load_playing_wiki();
    $('.dropdown-toggle').dropdown();
    $('.search-controls button').button();
});
