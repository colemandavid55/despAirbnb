var directionsDisplay;
var directionsService = new google.maps.DirectionsService();
var map;
var geocoder;
var grand_canyon = new google.maps.LatLng(36.1000, -112.1000);
var locations;
var infowindow = null;
var contentString = [];


function initialize() {
  directionsDisplay = new google.maps.DirectionsRenderer();
  //calcRoute();
  var mapOptions = {
    center: grand_canyon,
    zoom: 8
  };
  /* Delete previous map here */
  // document.getElementById("map-canvas").empty();
  $('#map-canvas').empty();
  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
  directionsDisplay.setMap(map);

  infowindow = new google.maps.InfoWindow({
        content: "holding..."
  });

  /*$.get("/dummy",function(data,status){
    locations = jQuery.parseJSON("" + data);
    dropPins(locations)
  });*/
}

function calcRoute(num_guests, mi_range) {
  var selectedMode = "DRIVING" 
  var request = {
      origin: $( "input[name='location']" ).val(),
      destination: $( "input[name='destination']" ).val(),
      travelMode: google.maps.TravelMode[selectedMode]
  };
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsDisplay.setDirections(response);
      var mypath = response.routes[0].overview_path;
      var submitpath = [];
      for (var x=0; x < mypath.length; x++){
        submitpath.push([mypath[x].k, mypath[x].D]);
      }
      // console.log(submitpath)
      // console.log(num_guests)
      // console.log(mi_range)

      $.post("/rooms",
      {
        route: JSON.stringify(submitpath),
        guests: num_guests,
        range: mi_range
      }).done(function(data){
        locations = jQuery.parseJSON("" + data);
        dropPins(locations)
        $('button').prop("disabled", false); //re-enable search button after pins are dropped for new searches.
      });
    }

  });
}


function codeAddress(address) {
  geocoder.geocode( { 'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      map.setCenter(results[0].geometry.location);
      var marker = new google.maps.Marker({
          map: map,
          position: results[0].geometry.location
      });
    } else {
      alert('Geocode was not successful for the following reason: ' + status);
    }
  });
}

function dropPins(rooms) {
  // Create a Maker and drop marker for each location
  for (var i=0; i < rooms.length; i++){
    // console.log(rooms[i]["room_id"])

    room = rooms[i]

    var latlng = new google.maps.LatLng(parseFloat(room.latitude), parseFloat(room.longitude))

    /* Add The Place ID so we can identify it onclick() */
    var latlng = new google.maps.LatLng(parseFloat(room.latitude), parseFloat(room.longitude))

    var place = {
      location: latlng,
      placeId: room.room_id.toString()
    }

    var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        place: place
    });

    google.maps.event.addListener(marker, 'click', function() {

      

      $.get('/rooms/' + this.getPlace().placeId)
      .done(function(data,status){
        var room = JSON.parse(data)
        var htmlClickContent = '<div id="'+room.room_id+'">'+
            '<div id="siteNotice">'+
            '</div>'+
            '<h2 id="mainHeading" class="mainHeading">'+room.name + ' - $' + room.price +'</h1>'+
            '<div id="bodyContent">'+
              '<p><img src='+room.imgUrl+'></img></p>'+
              '<p><a href="'+room.roomUrl+'"><b>'+ 
                room.name + " - " + room.location + ' - $' + room.price + '</b></a></p>'
            '</div>'+
            '</div>';

        infowindow.setContent(htmlClickContent);       
      });
      map.panTo(this.getPosition());
      infowindow.open(map, this);
    });

    google.maps.event.addListener(marker, 'mouseover', function() {

      $.get('/rooms/' + this.getPlace().placeId)
      .done(function(data,status){
        var room = JSON.parse(data)

        var htmlMouseoverContent = '<div id="'+room.room_id+'">'+
            '<h3 id="prevHeading" class="prevHeading">'+room.name + ' - $' + room.price +'</h3>'+
            '<div id="bodyContent">'+
            '<p><img src='+room.imgUrl+' class="qtr"></img></p>'+
            '</div>'+
            '</div>';

        infowindow.setContent(htmlMouseoverContent);  
      });
      infowindow.open(map, this); 
    });
  }
}

google.maps.event.addDomListener(window, 'load', initialize);


function genRooms() {
  var num_guests = $( "select[name='guests']" ).val();
  var mile_range = $( "select[name='range']" ).val();
  $('#map-canvas').css( { height: $(window).innerHeight()}); // adjust the map div to fit the window after search.
  google.maps.event.trigger(window, 'load', initialize); // reload the map to get rid of the old query.
  google.maps.event.trigger(map, 'resize'); // fit the actual map into the resized div
  $('button').prop("disabled", true); //disable the search button to prevent multiple queries
  calcRoute(num_guests, mile_range);
}

