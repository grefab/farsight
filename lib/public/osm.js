function OSM() {
	var proj4326 = new OpenLayers.Projection("EPSG:4326");
	var projmerc = new OpenLayers.Projection("EPSG:900913");
	
	this.init_map = function () {
	    var lonlat = new OpenLayers.LonLat(13.38, 52.52);
	    var zoom = 13;
	
	    this.map = new OpenLayers.Map("map", {
	            controls: [
	                new OpenLayers.Control.KeyboardDefaults(),
	                new OpenLayers.Control.Navigation(),
	                new OpenLayers.Control.LayerSwitcher(),
	//                new OpenLayers.Control.PanZoomBar(),
	//                new OpenLayers.Control.MousePosition()
	            ],
	            maxExtent:
	                new OpenLayers.Bounds(-20037508.34,-20037508.34,
	                                       20037508.34, 20037508.34),
	            numZoomLevels: 18,
	            maxResolution: 156543,
	            units: 'm',
	            projection: projmerc,
	            displayProjection: proj4326
	    } );
	
	    var mapnik_layer = new OpenLayers.Layer.OSM.Mapnik("Mapnik");
	    var tah_layer = new OpenLayers.Layer.OSM.Osmarender("Tiles@Home");
	    this.map.addLayers([mapnik_layer, tah_layer]);
	
	    lonlat.transform(proj4326, projmerc);
	    this.map.setCenter(lonlat, zoom);
	}
	
	this.init_marker = function () {
	    this.markerLayer = new OpenLayers.Layer.Markers("Markers");
	    this.map.addLayer(this.markerLayer);
	}

	this.center_map = function( lonLat ) {
		this.map.setCenter( lonLat );
	}
	
	this.map_overview_markers = function() {
		this.map.zoomToExtent( this.markerLayer.getDataExtent() );
	}

	this.add_marker = function( lonLat ) {
	    var size = new OpenLayers.Size(32, 32);
	    var offset = new OpenLayers.Pixel(-22, -30);
	    var icon = new OpenLayers.Icon('/pin-32x32.png', size, offset);
	    var marker = new OpenLayers.Marker(lonLat.transform(proj4326, projmerc), icon);

	    this.markerLayer.addMarker(marker);
	}
	
	this.clear_markers = function () {
		for(var i=0;i < this.markerLayer.markers.length;i++)
		{
		    var mrkr = this.markerLayer.markers[i];
			this.markerLayer.removeMarker(mrkr);
		} 
	}
	
	this.move_marker = function( newLonLat ) {
		this.clear_markers();
		this.add_marker( newLonLat );
	}
}
