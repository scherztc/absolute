
function showMoreOrLess(e){
  $(this).toggle();
  $(this).siblings().toggle();
}

Blacklight.onLoad(function() {
  $('#documents .show-more').bind('click', {}, showMoreOrLess);
  $('#documents .show-less').bind('click', {}, showMoreOrLess);
})

