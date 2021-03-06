/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

function getMediaFilePath(mediaItem) {
  return "ext-content/" + mediaItem.dir + '/' + mediaItem.title +
    mediaItem.file_ext;
}

/*
 * Parameter -- iconClass is a string name of fontawesome class name.
 */
function createIconSpan(iconClass) {
  return $('<span/>', {
    "class": "webix_icon"
  }).addClass(iconClass).get(0).outerHTML;
}

function renderMedia(headerTitle, mediaElement, onCloseAction) {
  webix.ui({
    view: "window",
    id: "media_window",
    fullscreen: true,
    head: {
      view: "toolbar",
      margin: -10,
      cols: [{
        view: "label",
        label: headerTitle
      }, {
        view: "icon",
        icon: "times-circle",
        click: function() {
          onCloseAction();
          $$('media_window').close();
        }
      }]
    },
    body: {
      padding: 0,
      rows: [{
        // Ensures URL encoding is applied to the src URL
        template: mediaElement.get(0).outerHTML
      }]
    }
  }).show();
}

function renderPdf(mediaItem) {
  // Note embed nor iframe works great to render pdf. So, this is workaround until better alternative is found.
  window.location = getMediaFilePath(mediaItem);
}

function renderText(mediaItem) {
  renderMedia(mediaItem.title, $("<iframe/>", {
    id: "iframe_elm",
    src: getMediaFilePath(mediaItem),
    type: "application/text",
    width: "100%",
    height: "100%"
  }), function() {
    // no-op
  });
}

function renderDoc(mediaItem) {
  var mediaType = mediaItem.file_ext.toString().toLowerCase();
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

function renderAudio(mediaItem) {
  renderMedia(mediaItem.title, $("<audio/>", {
    id: "audio_elm",
    src: getMediaFilePath(mediaItem),
    type: "audio/mp3", // TODO  mediaItem.file_ext.toString().substring(1).toLowerCase();
    width: "100%",
    controls: true
  }), function() {
    $("#audio_elm")[0].pause();
  });
}

function renderVideo(mediaItem) {
  renderMedia(mediaItem.title, $("<video/>", {
    id: "video_elm",
    src: getMediaFilePath(mediaItem),
    type: "video/mp4", // TODO  mediaItem.file_ext.toString().substring(1).toLowerCase();
    width: "100%",
    controls: true
  }), function() {
    $("#video_elm")[0].pause();
  });
}

//
// Photo viewer is still under construction.
//

function renderPhoto(mediaItem) {
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
    return '<img src="' + obj.src +
      '" class="content" ondragstart="return false"/><div class="title">' + obj.title +
      '</div>';
  }
  console.log("This should be called only once.");
  var imageFilePaths = [];
  media_file_list.forEach(function(media_file) {
    if (media_file.category.toString().toLowerCase() == "photos") {
      imageFilePaths.push({
        id: media_file.id,
        css: "image",
        template: img,
        data: webix.copy({
          src: getMediaFilePath(media_file),
          title: media_file.title
        })
      });
    }
  });
  $("body").data("image file list", imageFilePaths);
}

/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  // keep the retrieved data in a cache for later use.
  cacheImageFilePaths(result);
  webix.ui({
    id: "media_list_renderer",
    margin: 5,
    padding: 0,
    type: "wide",
    view: "flexlayout",
    cols: [{
      container: "media_list",
      view: "grouplist",
      templateBack: "{common.categoryIcon()} #value#",
      templateGroup: "{common.categoryIcon()} #value#",
      templateItem: "{common.fileIcon()} #title#",
      select: true,
      scroll: true,
      type: {
        /*
            "documents": ('.pdf', '.txt'),
            "books": ('.pdf', '.txt'),
            "music": ('.mp3', '.ogg'),
            "photos": ('.png', '.jpg'),
            "tv": ('.mp4', '.webm'),
            "videos": ('.mp4', '.webm')
         */
        fileIcon: function(mediaItem) {
          var faIconClass;
          switch (mediaItem.file_ext.toString().toLowerCase()) {
            case ".pdf":
              faIconClass = "fa-file-pdf-o";
              break;
            case ".txt":
              faIconClass = "fa-file-text-o";
              break;
            case ".mp4":
            case ".webm":
              faIconClass = "fa-file-movie-o";
              break;
            case ".mp3":
            case ".ogg":
              faIconClass = "fa-file-audio-o";
              break;
            case ".png":
            case ".jpg":
              faIconClass = "fa-file-picture-o";
              break;
            default:
              faIconClass = "fa-file";
          }
          return createIconSpan(faIconClass);
        },
        categoryIcon: function(mediaItem) {
          var faIconClass;
          switch (mediaItem.value.toString().toLowerCase()) {
            case "videos":
              faIconClass = "fa-film";
              break;
            case "documents":
              faIconClass = "fa-file-o";
              break;
            case "books":
              faIconClass = "fa-book";
              break;
            case "music":
              faIconClass = "fa-music";
              break;
            case "tv":
              faIconClass = "fa-desktop"; // webix does not support fa-tv yet.
              break;
            case "photos":
              faIconClass = "fa-image";
              break;
            default:
              faIconClass = "fa-github";
              break;
          }
          return createIconSpan(faIconClass);
        }
      },
      scheme: {
        $group: {
          by: 'category'
        },
        $sort: {
          by: "value",
          dir: "desc"
        }
      },
      on: {
        onSelectChange: function() {
          var mediaItem = this.getSelectedItem();
          if (mediaItem == undefined) {
            // Case unselectAll event happens.
            return;
          }
          if (mediaItem.category == 'videos' || mediaItem.category == 'tv') {
            renderVideo(mediaItem);
          } else if (mediaItem.category == 'documents' || mediaItem.category ==
            'books') {
            renderDoc(mediaItem);
          } else if (mediaItem.category == 'music') {
            renderAudio(mediaItem);
          } else if (mediaItem.category == 'photos') {
            renderPhoto(mediaItem);
            // webix.message("Feature is coming soon!");
          } else {
            webix.message("Unsupported type" + mediaItem.category);
          }
          $$(this).unselectAll();
        }
      },
      data: webix.copy(result)
    }]
  });
}); // end of getJSON()
