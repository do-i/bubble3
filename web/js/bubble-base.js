/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

$(function() {
  var scriptEls = document.getElementsByTagName('script');
  var thisScriptEl = scriptEls[scriptEls.length - 1];
  var scriptPath = thisScriptEl.src;
  var bubbleHome = scriptPath.substr(0, scriptPath.lastIndexOf('/js/') + 1);
  var background = bubbleHome + 'img/background.jpg'
  $.supersized({
    slides: [{
      image: background,
      title: 'Custom Be G'
    }]
  });
});
