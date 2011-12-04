function Loc4te() {
	var osm = new OSM();

	this.init = function() {
		osm.init_map();
		osm.init_marker();
	}
	
	this.run_selflocate = function() {
	    osm.move_marker( new OpenLayers.LonLat(13.3776, 52.5162) );
		
		var positionFinder = new PositionFinder();
		positionFinder.getLocation( function(data) {
        	var newLonLat = new OpenLayers.LonLat(data.coords.longitude, data.coords.latitude);
			osm.move_marker( newLonLat );
			osm.center_map( newLonLat );

	        $.post('/data', JSON.stringify(data), function(json_response) { /* we ignore the answer. this is fire and forget! */} );
		}); 
	}	

	this.run_recent_postings = function() {
		$.get('/recent/data', function( json_response ) {
			newMarkers = JSON.parse(json_response);
			
			osm.clear_markers();
			
			for( var i = 0; i < newMarkers.length; i++ ) {
				var lat = newMarkers[i].latitude;
				var lon = newMarkers[i].longitude;
				var lonlat = new OpenLayers.LonLat(lon, lat);
				osm.add_marker(lonlat);
			}			

			osm.map_overview_markers();
		});
	}	
	
}

function PositionFinder() {
    this.getLocation = function( handleFunc ) {
        if (navigator.geolocation) {
            var options = {
                enableHighAccuracy: true,
                maximumAge: 5000
            };
            
            this.watchId = navigator.geolocation.watchPosition( function(position) {
		        var timestamp;
		        if (position.timestamp.constructor.name == "Date") {
		            timestamp = position.timestamp.getTime();
		        }
		        else {
		            timestamp = position.timestamp;
		        }
		        
		        var data = {
		            "coords": position.coords,
		            "timestamp": timestamp
		        };
		
				handleFunc(data);
			}, null, options);
        }
        else {
            alert("Sorry. Your browser does not support finding out about your location.");
        }
    }

}
