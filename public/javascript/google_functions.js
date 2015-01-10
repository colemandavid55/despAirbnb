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
      console.log(submitpath)
      console.log(num_guests)
      console.log(mi_range)

      $.post("/rooms",
      {
        route: JSON.stringify(submitpath),
        guests: num_guests,
        range: mi_range
      }).done(function(data){
        locations = jQuery.parseJSON("" + data);
        dropPins(locations)
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

function dropPins(mylocations) {
  //locations is an array
  for (var i=0; i < mylocations.length; i++){
    console.log(mylocations[i]["room_id"])
    $.get('/rooms/' + mylocations[i]["room_id"],
      function(data,status){
       var curr = JSON.parse(data)
  
    var mycontent = '<div id="'+curr.room_id+'">'+
        '<div id="siteNotice">'+
        '</div>'+
        '<h1 id="firstHeading" class="firstHeading">'+curr.location+'</h1>'+
        '<div id="bodyContent">'+
        '<p><a href="'+curr.roomUrl+'"><b>'+curr.name+'</b></a></p>'+
        '<p>Price: $'+curr.price+'</p>'+
        '<p><img src='+curr.imgUrl+'></img></p>'+
        '</div>'+
        '</div>';

    var mypreview = '<p><a href="'+curr.roomUrl+'"><b>'+curr.name+'</b></a></p>';

    var marker = new google.maps.Marker({
        position: new google.maps.LatLng(parseFloat(curr.lattitude), parseFloat(curr.longitude)),
        map: map,
        title: curr.location,
        html: mycontent,
        prev: mypreview
    });

    google.maps.event.addListener(marker, 'click', function() {
      infowindow.setContent(this.html)
      infowindow.open(map, this);
    });

    google.maps.event.addListener(marker, 'mouseover', function() {
      infowindow.setContent(this.prev)
      infowindow.open(map, this);
    });
  })

  }

}

google.maps.event.addDomListener(window, 'load', initialize);

$(document).on('click', $("button"), function(e){
  e.preventDefault();
  var num_guests = $( "select[name='guests']" ).val();
  var mile_range = $( "select[name='range']" ).val();
  calcRoute(num_guests, mile_range);
});
