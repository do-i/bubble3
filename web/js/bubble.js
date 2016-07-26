/*!
 * Copyright 2016 Joji Doi
 * Licensed under the MIT license
 */
$.getJSON("data/video_list.json", function(result) {
  $.each(result, function(i, item) {
    $("#mediafiles").append(new Option(item.substring(0, item.length - 4), item));
  });
});
$("#mediafiles").change(function() {
  var selection = $("#mediafiles").val();
  if (selection == "mediaUnselected") {
    $("#video_pane").hide();
  } else {
    $("#video_elm").html();
    $("#video_elm").html('<source src="ext-content/' + selection +
      '" type="video/mp4"></source>');
    $("#video_pane").show();
    $("#video_elm").load();
  }
});
// $.each(data, function(i, item) {
//   var a = document.createElement("a");
//   a.appendChild(document.createTextNode(item.substring(0, item.length - 4)));
//   a.href = "#";
//   var li = document.createElement("li");
//   li.appendChild(a);
//   $("#mediafiles").append(li);
// });
//
// $("#mediafiles").change(function() {
//   alert("changed");
//   var selection = $("#mediafiles").val();
//   if (selection == "mediaUnselected") {
//     $("#video_pane").hide();
//   } else {
//     $("#video_elm").html();
//
//     $("#video_elm").html(
//       '<source src="https://media.w3.org/2010/05/sintel/trailer.mp4" type="video/mp4"></source>'
//     );
//     // $("#video_elm").html('<source src="ext-content/' + selection +
//     //   '" type="video/mp4"></source>');
//     $("#video_pane").show();
//     $("#video_elm").load();
//   }
// });
