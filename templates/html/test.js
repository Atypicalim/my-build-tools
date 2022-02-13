
/**
 * https://krasimirtsonev.com/blog/article/Javascript-template-engine-in-just-20-line
 * simple template renderer
 * @param {*} html 
 * @returns renderer func
 */

var template2renderer = function(html) {
    var re = /<%([^%>]+)?%>/g;
    var reExp = /(^( )?(if|for|else|switch|case|break|{|}))(.*)?/g;
    var code = 'var r=[];\\n';
    var cursor = 0
    var match;
    var add = function(line, js) {
        if (js) {
            code += line.match(reExp) ? line + '\\n' : 'r.push(' + line + ');\\n';
        } else {
            code += line != '' ? 'r.push(`' + line.replace(/"/g, '\\"') + '`);\\n' : '';
        }
        return add;
    }
    while(match = re.exec(html)) {
        add(html.slice(cursor, match.index))(match[1], true);
        cursor = match.index + match[0].length;
    }
    add(html.substr(cursor, html.length - cursor), false);
    code += 'return r.join("");';
    code = code.replace(/\\t+|\\r\\n+|\\n+/g, '');
    var fun = new Function(code);
    var renderer = function(args) {
        return fun.apply(args);
    }
    return renderer;
}