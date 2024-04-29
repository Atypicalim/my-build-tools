
const builder = require("../../builder");

const bldr = builder.html({});
bldr.setInput("./test.html");
bldr.containScript();
bldr.containStyle();
bldr.containImage();
bldr.setOutput("./target.html");
bldr.start();
