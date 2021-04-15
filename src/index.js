var p = require('./parser.js');

window.sql2agg = function(src, dest, errConsole) {
    try {
        const result = p.run(src.value);
        dest.value = result;
        src.title = "";
        src.style.borderColor = "";

        errConsole.style.borderColor = "";
        errConsole.value = "(Error messages will appear here.)";
    } catch (e) {
        errMsg = String(e);

        src.style.borderColor = "red";
        src.title = errMsg;

        errConsole.style.borderColor = "red";
        errConsole.value = errMsg;
    }

}

