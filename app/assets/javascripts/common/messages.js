function cross_register(win) {
    console.log('cross_register: loc=' + win.location);
    window.register_win(win);
    win.register_win(window);
}
function register_win(win) {
    console.log(window.location + ' register_win(' + win.location + ')');
    window.register_target(win)
}

function register_target(win) {
    console.log(window.name + " registering target " + win.name);
    $("body").eventposter('add_target',win);
}
function unregister_target(win) {
    console.log(window.name + " UN-registering target " + win.name);
    $("body").eventposter('rem_target',win);
}


