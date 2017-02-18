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
  var datas = [];
  $.each(mediaFiles, function(i, mediaItem) {
    datas.push({
      image: getMediaFilePath(mediaItem),
      thumb: getMediaThumbFilePath(mediaItem)
    });
  });
  Galleria.run('.galleria', {
    thumbnails: "lazy",
    dataSource: datas,
    responsive: true,
    height: 0.5,
    autoplay: true
  });

  // lazy load small chunks of thumbnails at a time
  Galleria.ready(function() {
    this.lazyLoadChunks(30, 1000);
  })
}); // end of getJSON()
