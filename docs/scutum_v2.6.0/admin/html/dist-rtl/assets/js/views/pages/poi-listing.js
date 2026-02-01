var $poiList = $('.sc-js-poi-list');
var map;

scutum.pages.poiListing = {};
scutum.pages.poiListing.init = function () {
	scutum.forms.common.rating();
	scutum.pages.poiListing.map();
};
scutum.pages.poiListing.map = function () {
	scutum.require(['gmaps', 'snazzy-infowindow'], function () {
		var options = {
			lat: 41.9027835,
			lng: 12.4963655,
			zoom: 14
		};
		map = new GMaps({
			el: '#sc-js-poi-map',
			lat: options.lat,
			lng: options.lng,
			zoom: options.zoom
		});
		// set center on window resize
		function resize () {
			var lat = options.lat;
			var lng = options.lng;
			map.refresh();
			map.setCenter(lat, lng);
		}
		scutum.$win.on('resize', scutum.helpers.debounce(resize, 200));
		// styled maps
		var styles = [
			{
				"featureType": "water",
				"elementType": "geometry",
				"stylers": [
					{
						"color": "#e9e9e9"
					},
					{
						"lightness": 17
					}
				]
			},
			{
				"featureType": "landscape",
				"elementType": "geometry",
				"stylers": [
					{
						"color": "#f5f5f5"
					},
					{
						"lightness": 20
					}
				]
			},
			{
				"featureType": "road.highway",
				"elementType": "geometry.fill",
				"stylers": [
					{
						"color": "#ffffff"
					},
					{
						"lightness": 17
					}
				]
			},
			{
				"featureType": "road.highway",
				"elementType": "geometry.stroke",
				"stylers": [
					{
						"color": "#ffffff"
					},
					{
						"lightness": 29
					},
					{
						"weight": 0.2
					}
				]
			},
			{
				"featureType": "road.arterial",
				"elementType": "geometry",
				"stylers": [
					{
						"color": "#ffffff"
					},
					{
						"lightness": 18
					}
				]
			},
			{
				"featureType": "road.local",
				"elementType": "geometry",
				"stylers": [
					{
						"color": "#ffffff"
					},
					{
						"lightness": 16
					}
				]
			},
			{
				"featureType": "poi",
				"elementType": "geometry",
				"stylers": [
					{
						"lightness": 10
					}
				]
			},
			{
				"featureType": "poi.park",
				"elementType": "geometry",
				"stylers": [
					{
						"color": "#dedede"
					},
					{
						"lightness": 21
					}
				]
			},
			{
				"elementType": "labels.text.stroke",
				"stylers": [
					{
						"visibility": "on"
					},
					{
						"color": "#ffffff"
					},
					{
						"lightness": 16
					}
				]
			},
			{
				"elementType": "labels.text.fill",
				"stylers": [
					{
						"saturation": 36
					},
					{
						"color": "#333333"
					},
					{
						"lightness": 40
					}
				]
			},
			{
				"elementType": "labels.icon",
				"stylers": [
					{
						"visibility": "off"
					}
				]
			},
			{
				"featureType": "transit",
				"elementType": "geometry",
				"stylers": [
					{
						"color": "#f2f2f2"
					},
					{
						"lightness": 19
					}
				]
			},
			{
				"featureType": "administrative",
				"elementType": "geometry.fill",
				"stylers": [
					{
						"color": "#fefefe"
					},
					{
						"lightness": 20
					}
				]
			},
			{
				"featureType": "administrative",
				"elementType": "geometry.stroke",
				"stylers": [
					{
						"color": "#fefefe"
					},
					{
						"lightness": 17
					},
					{
						"weight": 1.2
					}
				]
			}
		];
		map.addStyle({
			styledMapName: "Ultra Light with Labels",
			styles: styles,
			mapTypeId: "snazzyMaps-151"
		});
		map.setStyle("snazzyMaps-151");
		scutum.helpers.ajax('data/pages/poi.json', 'GET', 'json').then(function (markers) {
			// add markers
			markers.forEach(function (marker) {
				var icon = marker.main ? "assets/img/map-marker-main.svg" : "assets/img/map-marker.svg";
				var _marker = map.addMarker({
					lat: marker.lat,
					lng: marker.lng,
					title: marker.title,
					icon: icon,
					click: function (e) {
						// console.log(marker.address);
					}
				});
				var bodyText = marker.address || marker.info;
				var content = '<div class="sc-iw-title">' + marker.title + '</div><div class="sc-iw-body">' + bodyText + '</div><div class="sc-iw-footer"><a href="' + marker.link + '"  class="sc-link-external" target="_blank"><span>Wikipedia</span></a></div>';
				var id = marker.id;
				var infoWindow = new SnazzyInfoWindow({
					marker: _marker,
					content: content,
					maxWidth: 320,
					closeButtonMarkup: '<button type="button" class="uk-button uk-button-link sc-iw-close"><i class="mdi mdi-close"></i></button>',
					closeWhenOthersOpen: true,
					border: false,
					callbacks: {
						open: function () {
							$poiList.find('[data-poi-id="' + id + '"]').addClass('uk-active');
							var wrapper = infoWindow.getWrapper();
							$(wrapper).find('.sc-iw-close').on('click', function () {
								infoWindow.close();
							});
						},
						close: function () {
							$poiList.find('[data-poi-id="' + id + '"]').removeClass('uk-active');
						}
					}
				});
				$poiList.on('click', '[data-poi-id="' + id + '"]', function () {
					// map.setZoom(18);
					var lat = scutum.helpers.mq.mediumMin() ? marker.lat : parseFloat(marker.lat) + parseFloat('0.006');
					map.once('idle', function () {
						infoWindow.open();
					});
					map.setCenter(lat, marker.lng, function () {
						var zoom = map.getZoom();
						if (zoom < options.zoom) {
							map.setZoom(options.zoom);
						}
						if (scutum.helpers.mq.mediumMax() && scutum.$offcanvas.length) {
							UIkit.offcanvas(scutum.$offcanvas).hide();
						}
					});
				});
			});
			// fit zoom level to show all markers in the viewport
			map.fitZoom();
		})
	}, false);
};
