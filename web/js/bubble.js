/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */

/*
 * Load media_list from the json file
 */
$.getJSON("data/media_files_list.json", function(result) {
  console.log(result);
  webix.ui({
    margin: 10,
    padding: 0,
    type: "wide",
    view: "flexlayout",
    cols: [{
      container: "media_list_poc",
      view: "grouplist",
      templateBack: " Category #category#",
      templateGroup: " Category #value#",
      templateItem: "#title#",
      select: true,
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
          var media_item = this.getSelectedItem();
          console.log(media_item);
          console.log(media_item.title);
          console.log(media_item.file_ext);
          console.log(media_item.dir);
        }
      },
      data: webix.copy(result)
    }]
  });

  //
  // if (result.hasOwnProperty("videos")) {
  //   $.each(result["videos"]["files"], function(i, item) {
  //     var btnDiv = $("<div></div>", {
  //       "class": "col-xs-12 col-sm-6 col-md-4 col-lg-3 top-margin-1"
  //     }).appendTo("#files_list");
  //
  //     var btn = $("<button></button>", {
  //       "type": "button",
  //       "class": "btn btn-bubble btn-lg btn-block",
  //       "data-toggle": "modal",
  //       "data-target": "#video_modal",
  //       "value": item
  //     }).appendTo(btnDiv);
  //     btn.html(item.substring(0, item.lastIndexOf('.')));
  //     btn.on("click", function() {
  //       var selection = $(this).val();
  //       $("#video_elm").empty(); // clear previous source element
  //       var video_src = $("<source/>", {
  //         "src": "ext-content/" + result['videos']['dir'] + '/' + selection,
  //         "type": "video/mp4"
  //       }).appendTo("#video_elm");
  //       $("#video_elm").load();
  //     });
  //   });
  // } // end if json has videos section
  //
  // if (result.hasOwnProperty("documents")) {
  //   $.each(result["documents"]["files"], function(i, item) {
  //     var btnDiv = $("<div></div>", {
  //       "class": "col-xs-12 col-sm-6 col-md-4 col-lg-3 top-margin-1"
  //     }).appendTo("#files_list");
  //
  //     var btn = $("<button></button>", {
  //       "type": "button",
  //       "class": "btn btn-bubble btn-lg btn-block",
  //       "value": item
  //     }).appendTo(btnDiv);
  //     btn.html(item.substring(0, item.lastIndexOf('.')));
  //     btn.on("click", function() {
  //       var selection = $(this).val();
  //       window.location = "ext-content/" + result['documents']['dir'] + '/' + selection;
  //     });
  //   });
  // } // end if json has documents section
}); // end of getJSON()

/*
 * Pause the video when bootstrap modal is hidden.
 */
$("#video_modal").on("hide.bs.modal", function(e) {
  $("#video_elm")[0].pause();
})
