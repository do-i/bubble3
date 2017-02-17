/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

function getMediaThumbFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/thumbs/' + mediaItem.title +
    mediaItem.file_ext;
}

/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  var mediaFiles = $(result).filter(function() {
    return this.category == "photos";
  });
  $.each(mediaFiles, function(i, mediaItem) {
    // TODO add <a/> around <img> tag
    var aTag = $("<a/>", {
      "href": getMediaFilePath(mediaItem)
    });
    var img = $("<img/>", {
      "src": getMediaThumbFilePath(mediaItem)
    });
    img.appendTo(aTag);
    aTag.appendTo("#files_list");
  });
  Galleria.loadTheme('galleria/themes/classic/galleria.classic.min.js');
  $(".galleria").galleria({
    responsive: true,
    height: 0.5
  });
  Galleria.run('.galleria');

}); // end of getJSON()
