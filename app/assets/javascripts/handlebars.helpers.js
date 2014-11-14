
//https://gist.github.com/TastyToast/5053642
Handlebars.registerHelper ('truncate', function (str, len) {
    if ((str != undefined) && (str.length > len && str.length > 0)) {
        var new_str = str + " ";
        new_str = str.substr (0, len);
        new_str = str.substr (0, new_str.lastIndexOf(" "));
        new_str = (new_str.length > 0) ? new_str : str.substr (0, len);

        return new Handlebars.SafeString ( new_str +'...' );
    }
    return str;
});