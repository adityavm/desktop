const chalk = require("chalk");

const bars = "■■■■■■■";
const border = `${chalk.red(bars)}${chalk.blue(bars)}${chalk.green(bars)}${chalk.yellow(bars)}${chalk.cyan(bars)}`;
const sp = "\t";
const bigSp = "\t    ";
const initSp = "   ";

console.log(initSp, border);
console.log("");
console.log(`${initSp}${initSp}${sp}${chalk.gray("machine")}${bigSp}macOS Mojave`);
console.log(`${initSp}${initSp}${sp}${chalk.gray("wm")}${bigSp}slate`);
console.log(`${initSp}${initSp}${sp}${chalk.gray("font")}${bigSp}dank mono`);
console.log(`${initSp}${initSp}${sp}${chalk.gray("shell")}${bigSp}fish`);
console.log("");
console.log(initSp, border);
