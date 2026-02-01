scutum.plugins.gmaps = {};
scutum.plugins.gmaps.init = function () {
	scutum.require(['gmaps'], function () {
		// google maps markers
		scutum.plugins.gmaps.markers();
		// google maps route
		scutum.plugins.gmaps.route();
		// google maps custom colors
		scutum.plugins.gmaps.styled();
		// google maps static
		scutum.plugins.gmaps.static();
	});
};
scutum.plugins.gmaps.markers = function () {
	var map = new GMaps({
		div: '#sc-gmap-markers',
		lat: 41.9027835,
		lng: 12.4963655,
		zoom: 13
	});
	map.addMarker({
		lat: 41.8902102,
		lng: 12.4922309,
		title: 'Romes Colosseum',
		details: {
			id: 1,
			link: 'https://en.wikipedia.org/wiki/Colosseum'
		},
		click: function (e) {
			console.log(e);
		}
	});
	map.addMarker({
		lat: 41.8986108,
		lng: 12.4768729,
		title: 'Pantheon',
		details: {
			id: 2,
			link: 'https://en.wikipedia.org/wiki/Pantheon,_Rome'
		},
		click: function (e) {
			console.log(e);
		}
	});
};
scutum.plugins.gmaps.route = function () {
	var map = new GMaps({
		div: '#sc-gmap-route',
		lat: 41.9027835,
		lng: 12.4822309,
		zoom: 13
	});
	map.drawRoute({
		origin: [41.8902102, 12.4922309],
		destination: [41.8991632, 12.4730739],
		travelMode: 'driving',
		strokeColor: '#4527A0',
		strokeOpacity: 0.8,
		strokeWeight: 5
	});
};
scutum.plugins.gmaps.styled = function () {
	var map = new GMaps({
		div: '#sc-gmap-styled',
		lat: 41.9027835,
		lng: 12.4963655,
		zoom: 12
	});
	map.addStyle({
		styledMapName: "Blue water",
		styles: [
			{
				"featureType": "administrative",
				"elementType": "labels.text.fill",
				"stylers": [
					{
						"color": "#444444"
					}
				]
			},
			{
				"featureType": "landscape",
				"elementType": "all",
				"stylers": [
					{
						"color": "#f2f2f2"
					}
				]
			},
			{
				"featureType": "poi",
				"elementType": "all",
				"stylers": [
					{
						"visibility": "off"
					}
				]
			},
			{
				"featureType": "road",
				"elementType": "all",
				"stylers": [
					{
						"saturation": -100
					},
					{
						"lightness": 45
					}
				]
			},
			{
				"featureType": "road.highway",
				"elementType": "all",
				"stylers": [
					{
						"visibility": "simplified"
					}
				]
			},
			{
				"featureType": "road.arterial",
				"elementType": "labels.icon",
				"stylers": [
					{
						"visibility": "off"
					}
				]
			},
			{
				"featureType": "transit",
				"elementType": "all",
				"stylers": [
					{
						"visibility": "off"
					}
				]
			},
			{
				"featureType": "water",
				"elementType": "all",
				"stylers": [
					{
						"color": "#46bcec"
					},
					{
						"visibility": "on"
					}
				]
			}
		],
		mapTypeId: "snazzyMaps-25"
	});
	map.setStyle("snazzyMaps-25");
};
scutum.plugins.gmaps.static = function () {
	var url = GMaps.staticMapURL({
		size: [640, 360],
		lat: 41.9027835,
		lng: 12.4963655,
		zoom: 13,
		markers: [
			{
				lat: 41.9064878,
				lng: 12.4536413
			},
			{
				lat: 41.8902102,
				lng: 12.4922309,
				size: 'small'
			},
			{
				lat: 41.8955854,
				lng: 12.4721632,
				color: 'blue'
			}
		]
	});

	$('<img src=""/>').attr('src', url + '&key=' + scutum.config.gmapsKey).appendTo('#sc-gmap-static');
};
