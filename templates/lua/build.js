
const builder = require("../../builder");

const bldr = builder.lua({});
bldr.setInput('./example.lua');
bldr.setOutput('example');
bldr.start();
bldr.run();
