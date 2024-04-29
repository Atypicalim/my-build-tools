

const builder = require("../../builder");

// macro

// handle macro
// when found a [M] after comment tag is regarded as a macro
// template: [M[ command | argument ]M]

const bldr = builder.code({});

bldr.setInput("./test.code", "./other.code");
bldr.setComment("//");
bldr.setOutput("./target.code");
// a line with unhandled macro
bldr.onMacro((code, command, argument) => {
    if (command == "ALPHABETS") {
        return "// ALPHABETS ..."
    }
});
// a line without any macro
bldr.onLine((line) => {
    return line
});
bldr.start();
