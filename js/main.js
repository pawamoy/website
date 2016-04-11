$(document).ready(function() {
  $("h2, h3").each(function(i) {
    $(this).after("<a href=#contents>Back to the top</a>").next()
     .css("font-size", "0.8em")
     .css("padding", "2px 4px")
     .css("margin-bottom", "0")
     .css("text-align", "center")
     .css("vertical-align", "middle")
     .css("-ms-touch-action", "manipulation")
     .css("touch-action", "manipulation")
     .css("cursor", "pointer")
     .css("-webkit-user-select", "none")
     .css("-moz-user-select", "none")
     .css("-ms-user-select", "none")
     .css("user-select", "none")
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
});
