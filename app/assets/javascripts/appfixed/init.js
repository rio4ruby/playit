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
    $.get(data.wikiurl, function(dat) {
        console.log("LOADED: " + data.wikiurl);
        var wikid = "wiki-" + data.wikiname;
        $('.wiki-artist').removeClass('wiki-artist-active');
        var vc = $(dat)
            .wrapAll('<div></div>')
            .parent()
            .find(".infobox.vcard")
            .wrapAll('<div class="wiki-artist wiki-artist-active" ' + "id=" + wikid + '></div>')
            .parent();
        console.log(vc);
        $('#wikiside').append(vc);
        $('#' + wikid).find('a').attr('target','_blank');
    });
}
function load_playing_wiki() {
    $.getJSON('/home/playing_wiki', function(data) {
        var wikiname = data.wikiname;
        var sel = "#wiki-" + wikiname;
        if( ! $(sel).length) {
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
        console.log('#main-tabs showN id=' + $(event.target).attr('id') );
        if( $(event.target).attr('id') == 'tab-now-playing-link' ) {

            // $('#wikiside').on('trackcontrol trackplayer', function(event) {
            //     console.log("#wikiside caught " + event.type);
            // });
            $('#lyricside').off('trackplayer trackcontrol').on('trackplayer trackcontrol', function(event) {
                console.log("#lyricside caught " + event.type);
                $.ajax({
                    url: '/home/playing_lyrics'
                }).done(function(data) {
                    $('#lyricside').html(data);
                    load_playing_wiki();
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
        console.log($(event.target).attr('id'));
        if($(event.target).attr('id') == 'tab-now-playing-link') {
            console.log("TRUE");
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
    $('.dropdown-toggle').dropdown();
    $('.search-controlls button').button();
});