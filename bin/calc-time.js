#!/usr/bin/node

/*
 *
 *
 * Sources:
 * https://www.codegrepper.com/code-examples/javascript/convert+seconds+to+hours+minutes+seconds+javascript
 * https://gist.github.com/jamesseanwright/5ccedb4a2fad74d93352ef4a5fbaa516
 */

const parseArgs = (args) =>
  new Map(args.map((arg) => arg.match(/^--([a-z0-9-]+)=?(.*)$/i).slice(1)));
const args = parseArgs(process.argv.slice(2));

function usage() {
  console.log(`
    sum or substract duration values in format of hours:minutes:seconds (sum by default)

    ./calc-time.js
    \t--help
    \t--sub
    \t--time="10:10:10 10:11:12 03:34:53"
  `);
}

function toSeconds(time) {
  const [hours, minutes, seconds] = time.split(":");
  return Number(seconds) + Number(minutes) * 60 + Number(hours) * 60 * 60;
}

function sum(a, b) {
  console.log(a, b);
  return a + b;
}

function sub(a, b) {
  return a - b;
}

function convertHMS(value) {
  const sec = parseInt(value, 10); // convert value to number if it's string
  let hours = Math.floor(sec / 3600); // get hours
  let minutes = Math.floor((sec - hours * 3600) / 60); // get minutes
  let seconds = sec - hours * 3600 - minutes * 60; //  get seconds
  // add 0 if value < 10; Example: 2 => 02
  if (hours < 10) {
    hours = "0" + hours;
  }
  if (minutes < 10) {
    minutes = "0" + minutes;
  }
  if (seconds < 10) {
    seconds = "0" + seconds;
  }
  return hours + ":" + minutes + ":" + seconds; // Return is HH : MM : SS
}

if (args.has("help")) {
  usage();
} else {
  const times = (args.get("times") || "").split(" ");

  var totalSeconds = times.map(toSeconds).reduce(args.has("sub") ? sub : sum);
  console.log(convertHMS(totalSeconds));
}
