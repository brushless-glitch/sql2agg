var p = require('./parser.js');

window.sql2agg = function(src, dest) {
    try {
        const result = p.run(src.value);
        dest.value = result;
        src.title = ""
        src.style.borderColor = ""
    } catch (e) {
        src.style.borderColor = "red"
        src.title = String(e);
    }

}

