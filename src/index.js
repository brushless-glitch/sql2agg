var p = require('./parser.js');

window.sql2agg = function(src, dest, errConsole) {
    try {
        const result = p.run(src.value);
        dest.value = result;
        src.title = "";
        src.style.borderColor = "";
    } catch (e) {
        errMsg = String(e);

        src.style.borderColor = "red";
        src.title = errMsg;

        errConsole.style.borderColor = "red";
        errConsole.value = errMsg;
    }

}

