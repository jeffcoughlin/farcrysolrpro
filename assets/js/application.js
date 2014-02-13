function populateDownloadMenu() {

	$.ajax({
		url: "update.json",
		method: "GET",
		dataType: "json",
		success: function (data, status, req) {

			var link = $("#stable-dl a");
			link.attr("href",data[0].downloads[0].url);
			link.html('<i class="icon-download-alt"></i> Download v' + data[0].version + ' ' + data[0].downloads[0].shortdesc + ' [' + data[0].downloads[0].size + ']');

			var nosolrLink = $("#stable-dl-nosolr a");
			nosolrLink.attr("href",data[0].downloads[1].url);
			nosolrLink.html('<i class="icon-download-alt"></i> Download v' + data[0].version + ' ' + data[0].downloads[1].shortdesc + ' [' + data[0].downloads[1].size + ']');

		}
	});

}

function updateRequirements() {
	$.ajax({
		url: "update.json",
		method: "GET",
		dataType: "json",
		success: function (data, status, req) {

			var requirements = $("ul.requirements");
			requirements.find("li").each(function(i){
				switch (i) {
					case 0:
						// cfml
						$(this).text(data[0].requirements.cfml.join(", "));
						break;
					case 1:
						// farcry
						$(this).text("FarCry " + data[0].requirements.farcry.join(", "));
						break;
					case 2:
						// solr
						$(this).text("Solr " + data[0].requirements.solr.join(", ") + " (optionally included)");
						break;
					default:
						break;
				}
			});

		}
	});
}

$(document).ready(function(){

    // fix sub nav on scroll
    var $win = $(window)
      , $nav = $('.subnav')
      , navTop = $('.subnav').length && $('.subnav').offset().top - 40
      , isFixed = 0

    processScroll()

    $win.on('scroll', processScroll)

    function processScroll() {
      var i, scrollTop = $win.scrollTop()
      if (scrollTop >= navTop && !isFixed) {
        isFixed = 1
        $nav.addClass('subnav-fixed')
      } else if (scrollTop <= navTop && isFixed) {
        isFixed = 0
        $nav.removeClass('subnav-fixed')
      }
    }

	populateDownloadMenu();
	updateRequirements();

});