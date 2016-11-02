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

function rendarMedia(id, headerTitle, mediaElement) {
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
          $(id)[0].pause();
          $$('media_window').close();
        }
      }]
    },
    body: {
      padding: 1,
      rows: [{
        // Ensures URL encoding is applied to the src URL
        template: mediaElement.get(0).outerHTML
      }]
    }
  }).show();
}

function rendarPdf(mediaItem) {
  window.location = getMediaFilePath(mediaItem);
}

function rendarAudio(mediaItem) {
  rendarMedia("#audio_elm", mediaItem.title, $("<audio/>", {
    id: "audio_elm",
    src: getMediaFilePath(mediaItem),
    type: "audio/mp3",
    width: "100%",
    controls: true
  }));
}

function rendarVideo(mediaItem) {
  rendarMedia("#video_elm", mediaItem.title, $("<video/>", {
    id: "video_elm",
    src: getMediaFilePath(mediaItem),
    type: "video/mp4",
    width: "100%",
    controls: true
  }));
}

function rendarPhoto(mediaItem) {
  function img(obj) {
    return '<img src="' + obj.src + '" class="content" ondragstart="return false"/>'
  }
  var mediaPath = getMediaFilePath(mediaItem);
  webix.ui({
    view: "window",
    body: {
      view: "carousel",
      id: "carousel",
      width: 464,
      height: 275,
      cols: [{
        css: "image",
        template: img,
        data: {
          src: mediaPath
        }
      }, {
        css: "image",
        template: img,
        data: {
          src: mediaPath
        }
      }]
    },
    head: {
      view: "toolbar",
      type: "MainBar",
      elements: [{
        view: "label",
        label: "Photobook",
        align: 'left'
      }]
    }
  }).show();
}


/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {

  webix.ui({
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
          if (mediaItem.category == 'videos') {
            rendarVideo(mediaItem);
          } else if (mediaItem.category == 'documents') {
            rendarPdf(mediaItem);
          } else if (mediaItem.category == 'music') {
            rendarAudio(mediaItem);
          } else if (mediaItem.category == 'photos') {
            // rendarPhoto(mediaItem);
            webix.message("Feature is coming soon!");
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
