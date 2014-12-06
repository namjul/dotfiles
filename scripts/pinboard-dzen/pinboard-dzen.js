#!/usr/bin/env node

'use strict';

/*
 * Module Dependencies.
 */

var request = require('request');
var program = require('commander');
var CronJob = require('cron').CronJob;
var token = process.env['PINBOARD_TOKEN'];
var apiURL = 'https://api.pinboard.in/v1/';
var timestamp = null;
var exec = require('child_process').exec;

/**
 * Api Methodes.
 */

var api = {
  update: 'posts/update',
  all: 'posts/all',
  add: 'posts/add'
}

/**
 * CLI.
 */

program
  .option('-h, --href [href]', 'href')
  .option('-t, --title [title]', 'title')
  .parse(process.argv);

if(program.href && program.title) {
  markAsRead(program.href, program.title);
} else {
  // first check for pinpoards timestamp.
  check(function() {
    // start display dzen
    allToRead();

    //Cron job. check for updates every minute.
    new CronJob('* * * * *', function(){
      check();
    }, null, true);
  });

} 


/** 
 * pinboard api request wrapper.
 */

function get(methode, cb, queryString) {
  var qs = extend({
    auth_token: token,
    format: 'json'
  }, queryString);
  
  var params = {
    url: apiURL + api[methode],
    json: true,
    qs: qs
  };

  request.get(params, cb);
}

/**
 * Mark as read.
 */

function markAsRead(href, title) {
  get('add', function(err, res, body) {
    if (err){
      return console.error(err);
    }
    allToRead();
  }, {
    url: href,
    description: title,
    replace: 'yes',
    toread: 'no'
  });
}

/**
 * Get all still-to-read pins.
 */

function allToRead() {
  get('all', function(err, res, body) {
    if (err){
      return console.error(err);
    }
    var onlyToRead = body.filter(function(pin) {
      return pin.toread == 'yes';
    });

    var lines = ['PB',]

    onlyToRead.forEach(function(pin) {
      var link = '^ca(1, xdg-open 2>/dev/null ' + pin.href + ')' + pin.description + '^ca()';
      var markToRead = '^p(_RIGHT)^p(-20)^ca(1, pinboard-dzen -h ' + pin.href + ' -t ' + pin.description + ')^fg(red)x^fg()^ca()^p()^p()';
      lines.push('^p(+10)' + link + markToRead + '^p()');
    });

    // first kill all old dzen2 processes
    exec('pkill dzen2', function() {
      // show entries
      exec('echo "' + lines.join('\n') +'" | dzen2 -p -l "' + (lines.length - 1) + '" -m -tw 30 -h 25 -w 500 -x 280');
    });
  });
}

/**
 * check if new entries exist.
 */

function check(cb) {
  get('update', function(err, res, body) {
    if (err){
      return console.error(err);
    }

    if(!timestamp) {
      timestamp = Date.parse(body.update_time);
      cb();
    } else {
      if(timestamp < Date.parse(body.update_time)) {
        allToRead();
      }
    }

  });
}

/**
 * Extend helper.
 */

function extend(target) {
  var sources = [].slice.call(arguments, 1);
  sources.forEach(function (source) {
    for (var prop in source) {
      target[prop] = source[prop];
    }
  });
  return target;
}
