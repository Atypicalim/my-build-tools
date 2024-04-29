
const builder = require("../../builder");

const bldr1 = builder.c({});
bldr1.setInput('./client.c');
bldr1.setLibs("dyad");
bldr1.setOutput('client');
bldr1.start();

const bldr2 = builder.c({});
bldr2.setInput('./server.c');
bldr2.setLibs("dyad");
bldr2.setOutput('server');
bldr2.start();

const serverPath = __dirname + "./server.exe";
const clientPath = __dirname + "./client.exe";
const exec = require('child_process').exec;
exec(`Start ${serverPath}`);
exec(`Start ${clientPath}`);
