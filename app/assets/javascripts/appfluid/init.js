var init_playing_complete;

function init_playing() {
    console.log("init_playing()");
    $('#playing-playlist').load('/list_nodes');
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

$(document).ready(function() {
    if(!init_playing_complete) {
        init_playing_complete = true;
        init_playing();
    }
});