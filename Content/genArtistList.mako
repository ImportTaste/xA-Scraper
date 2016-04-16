## -*- coding: utf-8 -*-
<!DOCTYPE html>

<%!
import time
from settings import settings

%>




<%def name="genItemDiv(imageTitle, imagePath, imageDesc, imageID, seqNum)">

	<div>
		% if imageTitle:
		<h4>${seqNum} - ${imageTitle}</h4>
		% endif
		% if imagePath:
			<small>${imagePath.split("/")[-1]}</small><br>
			<img style='max-width:825px' src='/images/byid/${imageID}'>
		%endif
		% if imageDesc:

			<p>${imageDesc}</p>
		% endif

	</div>


</%def>




<%
startTime = time.time()

contentSources = {}
for key in settings["artSites"]:
	contentSources[settings[key]["shortName"]] = settings[key]


cur = sqlCon.cursor()


%>

<html>
<head>
	<meta charset="utf-8">
	<title>WAT WAT IN THE DOWNLOAD</title>
	<link rel="stylesheet" type="text/css" href="/style.css">
	<script type="text/javascript" src="/js/jquery-2.1.0.min.js"></script>
	<script type="text/javascript" src="/js/jquery.infinitescroll.js"></script>


</head>

<%namespace name="sideBar" file="genNavBar.mako"/>

<%

	shortnames = contentSources.keys()
%>


<H2>INDEX</H2>

<body>

% if siteSource in shortnames:
	<%
		print("Request = ", request)
		if "all" in request.params and request.params["all"] == "true":
			allImages = True
		else:
			allImages = False
		niceName = contentSources[siteSource]["dlDirName"]
		print(shortnames)

		chunkStep = 20
		# artistName, pageUrl, retreivalTime
		# chunk = int(chunk)
		print("pageNumberStr", pageNumberStr)
		pageNumber = int(pageNumberStr)
		pageNumber = pageNumber-1
		print(pageNumber)
		cur.execute('SELECT count(*) FROM retrieved_pages WHERE siteName=%s AND artistName=%s;', (siteSource, artist))
		itemNo = cur.fetchall()
		if allImages:
			cur.execute('SELECT itemPageTitle, downloadPath, itemPageContent, id, seqNum FROM retrieved_pages WHERE siteName=%s AND artistName=%s ORDER BY pageUrl ASC, seqNum ASC;', (siteSource, artist))
		else:
			cur.execute('SELECT itemPageTitle, downloadPath, itemPageContent, id, seqNum FROM retrieved_pages WHERE siteName=%s AND artistName=%s ORDER BY pageUrl ASC, seqNum ASC LIMIT %s OFFSET %s;', (siteSource, artist, chunkStep, pageNumber*chunkStep))
		imageIDs = cur.fetchall()
		## imageIDs.sort()
		# imageIDs = [link[0] for link in imageIDs]
		# imageIDs.sort()

	%>

	<div>
		${sideBar.getSideBar(sqlCon)}
		<div class="maindiv">
			<div class="subdiv mtMainId">
				<div class="contentdiv">

					<div style="margin-top: 10px;">
						<h2>${artist.title()}</h2>
						Items: ${itemNo[0][0]}
						<a href="${request.current_route_path()}?all=true">All Images</a>
					</div>
					<div id="contentChunk">
						<table border="1px">

								<%
								last = 1
								%>
								% for imageTitle, imagePath, imageDesc, imageID, seqNum in imageIDs:

									% if seqNum == last:
											</td>
										</tr>
									%endif

									% if seqNum == last:
										<tr>
											<td class="padded" width="950">
									%endif

									${genItemDiv(imageTitle, imagePath, imageDesc, imageID, seqNum)}


									<%
									last = seqNum
									%>

								% endfor
						</table>
					</div>

				% if not allImages:
					<div class="nav">
						<a id="nextPage" href="/source/byartist/${siteSource}/${artist}/${pageNumber + 1}">Next</a>
						<a id="prevPage"  href="/source/byartist/${siteSource}/${artist}/${1 if (pageNumber - 1) < 1 else int(pageNumber) - 1}">Previous</a>
					</div>
				% endif
				</div>
			</div>
		</div>
	<div>

% else:
	<h3> Invalid SiteSource!</h3>
% endif



<%
stopTime = time.time()
timeDelta = stopTime - startTime
%>

<p>This page rendered in ${timeDelta} seconds.</p>


	<script type="text/javascript">

		$('div#contentChunk table').infinitescroll({

			debug        : true,
			dataType     : 'html',
			navSelector  : "div.nav", // selector for the paged navigation (it will be hidden)
			nextSelector : "div.nav a#nextPage", // selector for the NEXT link (to page 2)
			itemSelector : "div#contentChunk table tr" // selector for all items you'll retrieve
		});
		$('div#contentChunk table').infinitescroll('resume');
	</script>


</body>
</html>