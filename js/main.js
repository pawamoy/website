$(document).ready(function() {
  $("a:contains('Back to')")
    .css("font-size", "0.8em")
    .css("display", "inline-block")
    .css("padding", "3px 6px")
    .css("margin-bottom", "0")
    .css("font-weight", "400")
    .css("line-height", "1.42857143")
    .css("text-align", "center")
    .css("white-space", "nowrap")
    .css("vertical-align", "middle")
    .css("-ms-touch-action", "manipulation")
    .css("touch-action", "manipulation")
    .css("cursor", "pointer")
    .css("-webkit-user-select", "none")
    .css("-moz-user-select", "none")
    .css("-ms-user-select", "none")
    .css("user-select", "none")
    .css("background-image", "none")
    .css("border", "1px solid transparent")
    .css("border-radius", "4px")
    .css("color", "#fff")
    .css("background-color", "rgba(0,30,180,0.5)")
    .hover(
      function() {
        $(this).css("background-color", "rgba(0,30,180,1)")
               .css("text-decoration", "none");
      },
      function() {
        $(this).css("background-color", "rgba(0,30,180,0.5)");
      });
});
