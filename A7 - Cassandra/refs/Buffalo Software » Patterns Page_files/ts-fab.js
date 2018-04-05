jQuery(document).ready(function(a){a(".ts-fab-tabs > div").hide();a(".ts-fab-tabs > div:first-child").show();a(".ts-fab-list li:first-child").addClass("active");a(".ts-fab-list li a").click(function(){a(this).closest(".ts-fab-wrapper").find("li").removeClass("active");a(this).parent().addClass("active");var b=a(this).attr("href");if(b.indexOf("#")!=-1){currentTabExp=b.split("#");b="#"+currentTabExp[1]}a(this).closest(".ts-fab-wrapper").find(".ts-fab-tabs > div").hide();a(b).show();return false})});
/*
     FILE ARCHIVED ON 18:51:51 Dec 05, 2013 AND RETRIEVED FROM THE
     INTERNET ARCHIVE ON 10:36:34 Apr 05, 2018.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     ALL OTHER CONTENT MAY ALSO BE PROTECTED BY COPYRIGHT (17 U.S.C.
     SECTION 108(a)(3)).
*/
/*
playback timings (ms):
  LoadShardBlock: 237.263 (3)
  esindex: 0.007
  captures_list: 259.338
  CDXLines.iter: 14.009 (3)
  PetaboxLoader3.datanode: 241.765 (4)
  exclusion.robots: 0.211
  exclusion.robots.policy: 0.185
  RedisCDXSource: 1.986
  PetaboxLoader3.resolve: 55.756
  load_resource: 102.0
*/