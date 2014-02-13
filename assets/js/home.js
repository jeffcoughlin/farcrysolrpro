function populateHomePageDownloadButtons() {

	$.ajax({
		url: "update.json",
		method: "GET",
		dataType: "json",
		success: function (data, status, req) {

			$(".hero-unit>a").each(function(i){

				if (i == 0) {
					// w/ solr
					$(this).attr('href',data[0].downloads[0].url);
					$(this).html('<i class="icon-download-alt icon-white"></i> Download v' + data[0].version + '<br><span style="font-size: .7em;" class="pull-right">' + data[0].downloads[0].shortdesc + ' [' + data[0].downloads[0].size + ']</span>');
				} else {
					// w/o solr
					$(this).attr('href',data[0].downloads[1].url);
					$(this).html('<i class="icon-download-alt icon-white"></i> Download v' + data[0].version + '<span style="font-size: .85em;" class="pull-right">&nbsp;&nbsp;' + data[0].downloads[1].shortdesc + ' [' + data[0].downloads[1].size + ']</span>');
				}

			});


		}
	});

}

$(document).ready(function(){
	populateHomePageDownloadButtons();
});