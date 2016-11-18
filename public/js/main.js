$('a.foodlink').on('click', function(){
   var target = $(this).attr('rel');
   $("#"+target).show().siblings("div").hide();
});


$('a.phonescreens').hover(function(){
   var target = $(this).attr('rel');
   $("#"+target).show().siblings("div").hide();
});