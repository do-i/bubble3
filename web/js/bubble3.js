/*
 * Copyright 2017 Joji Doi, Greg Mendez-Weeks
 * Licensed under the MIT license
 *
 * Format: http://jsbeautifier.org/
 * - with Indent with 2 spaces
 * - Remove all extra newlines
 * - Wrap lines near 110 characters
 * - Braces with control statement
 * - Add one indent level
 */
var jsonResult;
var mq = window.matchMedia("(min-width: 40em)");
var barContainer = document.getElementById("myScrollspy");
var bar = document.getElementById("navBar");
var isSafari = navigator.vendor && navigator.vendor.indexOf('Apple') > -1;
if (mq.matches && !isSafari) {
  bar.className = "nav nav-pills nav-stacked ";
  barContainer.className = "col-sm-1 bg-faded sidebar";
  // window width is at least 40em
} else {
  bar.className = "breadcrumb";
  barContainer.className = "breadcrumb-item";
  // window width is less than 40em
}

function decode(string) {
  return string.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>');
}

function resizeContent() {
  if (mq.matches && !isSafari) {
    bar.className = "nav nav-pills nav-stacked ";
    barContainer.className = "col-sm-1 bg-faded sidebar";
    // window width is at least 40em
  } else {
    bar.className = "breadcrumb";
    barContainer.className = "breadcrumb-item";
    // window width is less than 40em
  }
}

function getMediaFilePath(mediaItem, dirName) {
  return "ext-content" + decode(dirName + "/" + mediaItem.name);
}

function getExt(mediaItem) {
  var end = mediaItem.name.toString().toLowerCase();
  var ind = end.lastIndexOf(".");
  end = end.substring(ind);
  return end;
}

function renderPdf(mediaItem, dir) {
  // Note embed nor iframe works great to render pdf. So, this is workaround until better alternative is found.
  //window.location = getMediaFilePath(mediaItem, dir);
  $(".bubble-audio-title").text(mediaItem.name);
  $("#pdf_elm").empty(); // clear previous source element
  var pdf_src = $("<iframe></iframe>", {
    "src": getMediaFilePath(mediaItem, dir),
    "type": "application/pdf",
    "class": "txt",
  }).appendTo("#pdf_elm");
  $("#pdf_elm").load();
}

function renderText(mediaItem, dir) {
  $(".bubble-audio-title").text(mediaItem.name);
  $("#pdf_elm").empty(); // clear previous source element
  var pdf_src = $("<iframe></iframe>", {
    "src": getMediaFilePath(mediaItem, dir),
    "class": "txt",
    "height": "50em",
    "width": "100%"
  }).appendTo("#pdf_elm");
  $("#pdf_elm").load();
}

function renderDoc(mediaItem) {
  var mediaType = getExt(mediaItem);
  switch (mediaType) {
    case ".pdf":
      renderPdf(mediaItem);
      break;
    case ".txt":
      renderText(mediaItem);
      break;
    default:
      console.log("Unsupported media type " + mediaType);
  }
}

function renderAudio(mediaItem, dir) {
  $(".bubble-audio-title").text(mediaItem.name);
  $("#audio_elm").empty(); // clear previous source element
  var type = getExt(mediaItem).substring(1);
  var video_src = $("<source></source>", {
    "src": getMediaFilePath(mediaItem, dir),
    "type": "audio/" + type
  }).appendTo("#audio_elm");
  $("#audio_elm").load();
}

function renderVideo(mediaItem, dir) {
  var type = getExt(mediaItem).substring(1);
  $("#video_elm").empty(); // clear previous source element
  var sour = $("<source></source>", {
    "src": getMediaFilePath(mediaItem, dir),
    "type": "video/" + type,
  }).appendTo("#video_elm");
  $("#video_elm").load();
}

function renderPhoto(mediaItem, dir) {
  $("#img_elm").empty(); // clear previous source element
  var video_src = $("<img/>", {
    "src": getMediaFilePath(mediaItem, dir),
    "class": "modal-content"
  }).appendTo("#img_elm");
  $("#img_elm").load();
}
//
// Photo viewer is still under construction.
//
function renderPhotoOld(mediaItem) {
  webix.ui({
    view: "window",
    id: "image_window",
    fullscreen: true,
    head: {
      view: "toolbar",
      margin: -10,
      cols: [{
        view: "label",
        label: "~~ Images Beta ~~"
      }, {
        view: "icon",
        icon: "times-circle",
        click: function() {
          $$('image_window').close();
        }
      }]
    },
    body: {
      view: "carousel",
      id: "bubble_carousel",
      fullscreen: true,
      cols: getImageFilePathsFromCache()
    }
  });
  $$("bubble_carousel").setActive(mediaItem.id);
  $$("image_window").show();
}
/*
 * Retrieve cached image file path data.
 * See cacheImageFilePaths(media_file_list) function for cache creation.
 */
function getImageFilePathsFromCache() {
  return $("body").data("image file list");
}
/*
 * Save image file paths data in cache for later reuse via getImageFilePathsFromCache() function.
 */
function cacheImageFilePaths(media_file_list) {
  function img(obj) {
    return '<img src="' + obj.src + '" class="content" ondragstart="return false"/><div class="title">' + obj
      .name + '</div>';
  }
  console.log("This should be called only once.");
  var imageFilePaths = [];
  media_file_list.forEach(function(media_file) {
    if (media_file.type.toString().toLowerCase() == "photos") {
      imageFilePaths.push({
        id: media_file.id,
        css: "image",
        template: img,
        data: webix.copy({
          src: getMediaFilePath(media_file),
          title: media_file.name
        })
      });
    }
  });
  $("body").data("image file list", imageFilePaths);
}
var folderStack = [];

function renderMediaDynamic(mediaItem, title) {
  if (mediaItem.type == "directory") {
    var opened = false;
    var pos;
    var elementIcon;
    var element;
    var len = folderStack.length;
    elementIcon = document.getElementById(mediaItem.name + "Icon");
    for (var i = 0; i < folderStack.length; i++) {
      if (elementIcon.parentElement.parentElement.id + "/" + mediaItem.name == folderStack[i]) {
        opened = true;
        pos = i;
      }
    }
    if (opened) {
      for (var i = pos; i < len; i++) {
        element = document.getElementById(folderStack[i]);
        element.outerHTML = "";
        delete element;
        var elephant = document.getElementById(folderStack[i] + "bar");
        elephant.outerHTML = "";
        delete elephant;
        elementIcon.src = "img/folder.png";
      }
      for (var i = pos; i < len; i++) {
        folderStack.pop();
      }
    } else {
      elementIcon.src = "img/openFolder.png";
      folderStack.push(elementIcon.parentElement.parentElement.id + "/" + mediaItem.name);
      addNavBar(elementIcon.parentElement.parentElement.id + "/" + mediaItem.name);
      getFilesInDir(mediaItem.contents, elementIcon.parentElement.parentElement.id + "/" + mediaItem.name);
    }
  } else {
    switch (getExt(mediaItem)) {
      case ".ogg":
      case ".mp3":
        renderAudio(mediaItem, title);
        break;
      case ".pdf":
        renderPdf(mediaItem, title);
        break;
      case ".webm":
      case ".mp4":
        renderVideo(mediaItem, title);
        break;
      case ".png":
      case ".jpg":
        renderPhoto(mediaItem, title);
        break;
      case ".txt":
        renderText(mediaItem, title);
        mediaSrc = "img/textFile.png";
        break;
        //case "tv":
        // break;
      default:
        mediaSrc = "img/unreadable.png";
        break;
    }
  }
}

function getCurrentDir(title) {
  return title.substring(title.lastIndexOf("/") + 1);
}

function addNavBar(name) {
  var nam = name + "bar";
  var nav = $("<li></li>", {
    "class": "",
    "id": nam,
  });
  var txt = $("<a></a>", {
    "href": "#" + name
  });
  txt.html(getCurrentDir(name));
  txt.appendTo(nav);
  nav.appendTo("#navBar");
}

function getFilesInDir(dir, title) {
  var mediaDirs = jsonResult;
  var currentDir = getCurrentDir(title);
  var directory = $("<div></div>", {
    "id": title,
  });
  directory.appendTo("#files_list");
  var name = $("<h2>" + currentDir + "</h2>", {});
  name.appendTo(directory);
  $.each(dir, function(i, mediaItem) {
    var mediaSrc = getMediaFilePath(mediaItem, title);
    var divType = "img";
    var modalType = "";
    if (mediaItem.type == "directory") {
      mediaSrc = "img/folder.png";
    } else {
      switch (getExt(mediaItem)) {
        //   case "document":
        //  mediaSrc = mediaItem;
        //break;
        case ".ogg":
        case ".mp3":
          mediaSrc = "img/musicFile.png";
          modalType = "audio";
          break;
        case ".pdf":
          mediaSrc = "img/pdfFile.png";
          modalType = "pdf";
          break;
        case ".webm":
        case ".mp4":
          modalType = "video";
          divType = "video";
          break;
        case ".png":
        case ".jpg":
          modalType = "img";
          break;
        case ".txt":
          mediaSrc = "img/textFile.png";
          modalType = "pdf";
          break;
          //case "tv":
          // break;
        default:
          mediaSrc = "img/unreadable.png";
          break;
      }
    }
    var wrapper = $("<div></div>", {
      "class": "thumbContainer",
    });
    var image = $("<" + divType + "></" + divType + ">", {
      "id": mediaItem.name + "Icon",
      "class": "bubble_thumb",
      "data-toggle": "modal",
      "data-target": "#" + modalType + "_modal",
      "value": mediaItem,
      "src": mediaSrc
    });
    var lnk = $("<a></a>", {
      "class": "fileName",
      "data-toggle": "modal",
      "data-target": "#" + modalType + "_modal",
      "value": mediaItem
    });
    lnk.html(mediaItem.name);
    lnk.on("click", function() {
      renderMediaDynamic(mediaItem, title);
    });
    image.html(mediaItem.name);
    image.on("click", function() {
      renderMediaDynamic(mediaItem, title);
    });
    // wrapper.append(image);
    //wrapper.append(lnk);
    wrapper.appendTo(directory);
    lnk.appendTo(wrapper);
    image.appendTo(wrapper);
  });
}
$.getJSON("data/media_files_list_v3.json", function(result) {
  jsonResult = result;
  addNavBar("")
  getFilesInDir(result, "");
}); // end of getJSON()
$("#audio_modal").on("hide.bs.modal", function(e) {
  $("#audio_elm")[0].pause();
});
$("#video_modal").on("hide.bs.modal", function(e) {
  $("#video_elm")[0].pause();
});
