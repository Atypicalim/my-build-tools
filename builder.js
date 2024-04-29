/**
 * builder
 */


//  import available builders
// import { KEYS, TYPES, CONFIGS } from "./src/constants.js";
// import { MyCBuilder } from "./src/c_builder.js";
// import { MyLuaBuilder } from "./src/lua_builder.js";
// import { MyHtmlBuilder } from "./src/html_builder.js";
// import { MyCodeBuilder } from "./src/code_builder.js";
// import "readline";

const { MyCBuilder } = require("./src/c_builder.js");
const { MyLuaBuilder } = require("./src/lua_builder.js");
const { MyHtmlBuilder } = require("./src/html_builder.js");
const { MyCodeBuilder } = require("./src/code_builder.js");

const { js, files, terminal, tools } = require("./src/tools.js");

if (!globalThis.builder) {
    globalThis.builder = {};
}

const builder = globalThis.builder;
const UI_LENGTH = 48;
const builders = ["c", "lua", "html", "code"];
const tasks = [];

const MY_BUILDER_TEMPLATE = `
  const builder = require("builder");
  const task = builder.%s({
      name: "%s",
      debug: false,
      release: false,
      input: "./source.%s",
      output: "./target"
  }).start();
`;

function splitByUpper(word) {
    const res = [];
    const regex = /([A-Z][a-z]*)/g;
    let match;
    while ((match = regex.exec(word)) !== null) {
        res.push(match[0]);
    }
    return res;
}

function String_paddCenter(text, length, char) {
    return text.padStart((text.length + length)/2).padEnd(length)
}

async function builderInit() {
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log("|" + String_paddCenter("My Builder", UI_LENGTH, " ") + "|");
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log("| build.lua not found, creating ...");
    console.log("| please enter task name:");
    const taskName = await terminal.read_line();
    console.log("| please select task type:");
    const taskType = await terminal.read_selection(builders);
    const myBuilderText = string.format(MY_BUILDER_TEMPLATE, taskType, taskName, taskType, taskType);
    files.write('./build.lua', myBuilderText);
    console.log("| created!");
}

function builderHelp(obj) {
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log("|" + `${obj.__name__} Help`.center(UI_LENGTH, " ") + "|");
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    const confKeys = {};
    const objFuncs = {};
    const arr = [obj.__class__, obj.__class__.__super__];
    for (const cls of arr) {
        for (const key in cls) {
            const val = cls[key];
            if (typeof val === 'function' && key.startsWith("set")) {
                const words = splitByUpper(key);
                const name = words.join("_").toLowerCase();
                confKeys[name] = true;
            }
            if (typeof val === 'function' && !key.startsWith("_")) {
                objFuncs[key] = true;
            }
        }
    }
    console.log('| keys:');
    for (const key in confKeys) {
        console.log("| * " + key);
    }
    console.log('| funs:');
    for (const key in objFuncs) {
        console.log("| * " + key);
    }
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
}

function builderParse(obj, args) {
    for (const [k, v] of Object.entries(args)) {
        if (!js.is_text(k)) {
            throw new Error('Invalid argument key for builder: ' + String(k));
        }
        const wrds = k.toLowerCase().split("_");
        const name = wrds.reduce((accumulator, word) => {
            return accumulator + word.charAt(0).toUpperCase() + word.slice(1);
        }, "");
        const func = obj['set' + name];
        if (typeof func !== 'function') {
            throw new Error('Unknown argument key for builder: ' + String(k));
        }
        func.call(obj, v);
    }
}

function builderBuild(cls, argsOrName) {
    const obj = new cls(false);
    const fun = function (args) {
        builderParse(obj, args);
        obj.help = builderHelp;
        tasks.push(obj);
        return obj;
    };
    if (typeof argsOrName === 'string') {
        obj.setName(argsOrName);
        return fun;
    } else {
        return fun(argsOrName);
    }
}

builder.c = function (...args) {
    return builderBuild(MyCBuilder, ...args);
};

builder.lua = function (...args) {
    return builderBuild(MyLuaBuilder, ...args);
};

builder.html = function (...args) {
    return builderBuild(MyHtmlBuilder, ...args);
};

builder.code = function (...args) {
    return builderBuild(MyCodeBuilder, ...args);
};

builder.help = function () {
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log("|" + "builder help".center(UI_LENGTH, " ") + "|");
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log('| builders:');
    for (const v of builders) {
        console.log('|', "*", v);
    }
    console.log('| functions:');
    for (const k in builder) {
        if (!builders.includes(k)) {
            console.log('|', "*", k);
        }
    }
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
};

builder.tasks = function () {
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log("|" + "builder list".center(UI_LENGTH, " ") + "|");
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
    console.log('| tasks:');
    for (let i = 0; i < tasks.length; i++) {
        const obj = tasks[i];
        console.log('|', i + 1 + ".", obj.getName());
    }
    console.log("-" + "-".repeat(UI_LENGTH) + "-");
};

builder.find = function (name) {
    if (!js.is_text(name)) {
        throw new Error('Invalid task name for builder');
    }
    for (const obj of tasks) {
        if (obj.getName() === name) {
            return obj;
        }
    }
};

builder.tools = require("./src/tools.js");

if (require.main === module) {
    builderInit();
} else {
    module.exports = builder;
}
