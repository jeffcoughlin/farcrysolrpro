function loadCurrentRelease(data) {

	// loop over each table cell and set the contents
	$("table.current-release tbody tr td").each(function(i){

		var item = $(this);

		switch (i) {
			case 0:
				// version w/ github link
				item.html('<a href="' + data[0].repositoryurl + '">v' + data[0].version + '</a>');
				break;
			case 1:
				// release date
				item.text(data[0].releasedate);
				break;
			case 2:
				// min farcry
				item.text("FarCry " + data[0].requirements.farcry.join(", "));
				break;
			case 3:
				// min cfml
				item.html(data[0].requirements.cfml.join("<br>"));
				break;
			case 4:
				// min solr
				item.text("Solr " + data[0].requirements.solr.join(", "));
				break;
			case 5:
				// download buttons
				item.empty();
				for (var y = 0; y < data[0].downloads.length; y++) {
					var link = $('<a></a>');
					link.attr('href',data[0].downloads[y].url);
					link.addClass("btn");
					if (y == 0) {
						link.addClass("btn-primary");
					} else {
						link.addClass("btn-inverse");
						link.attr('style',"margin-top: 5px; clear: right;");
					}
					link.addClass("btn-small");
					link.html('<i class="icon-download-alt icon-white"></i>&nbsp;Download v' + data[0].version + '&nbsp;<span style="font-size: .85em;" class="pull-right">' + data[0].downloads[y].shortdesc + ' [' + data[0].downloads[y].size + ']</span>');
					item.append(link);
				}
				break;
			default:
				break;
		}

	});
}