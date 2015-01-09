var directionsDisplay;
var directionsService = new google.maps.DirectionsService();
var map;
var austin = new google.maps.LatLng(30.25, -97.75);
var dallas = new google.maps.LatLng(32.7758, -96.7967);
var waco = new google.maps.LatLng(31.5514, -97.1558);
var temple = new google.maps.LatLng(31.0936, -97.3622);
var locations = [waco,temple]
var infowindow = null;
var contentString = [];

function initialize() {
  directionsDisplay = new google.maps.DirectionsRenderer();
  calcRoute();
  var mapOptions = {
    center: austin,
    zoom: 9
  };
  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
  directionsDisplay.setMap(map);

  infowindow = new google.maps.InfoWindow({
        content: "holding..."
  });
}

function calcRoute() {
  var selectedMode = "DRIVING" //document.getElementById("mode").value;
  var request = {
      origin: austin,
      destination: dallas,
      // Note that Javascript allows us to access the constant
      // using square brackets and a string value as its
      // "property."
      travelMode: google.maps.TravelMode[selectedMode]
  };
  directionsService.route(request, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      directionsDisplay.setDirections(response);
      console.log(response.routes[0].overview_path[0].k + ", " + response.routes[0].overview_path[0].D)
      dropPins(locations)
    }
  });
}

function dropPins(mylocations) {
  //locations is an array
  for (var i=0; i < mylocations.length; i++){
  
    var mycontent = '<div id="content'+i+'">'+
        '<div id="siteNotice">'+
        '</div>'+
        '<h1 id="firstHeading" class="firstHeading">Location'+i+' Name Here</h1>'+
        '<div id="bodyContent">'+
        '<p><b>Location</b></p>'+
        '<p>Miles from Path?</p>'+
        '<p>Address</p>'+
        '</div>'+
        '</div>';

    var mypreview = '<p><b>Preview?</b></p>'

  
    var marker = new google.maps.Marker({
        position: mylocations[i],
        map: map,
        title: 'Location',
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
  }

  

}

google.maps.event.addDomListener(window, 'load', initialize);