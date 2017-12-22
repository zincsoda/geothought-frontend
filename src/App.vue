<template>
  
  <div id="app">
    <h4>Hover over flag to show mesage. Click on the map to change the location.</h4>
    <div id="my-map"></div>
    <div id="left">
      <h3>Current location</h3>
      <p>Coordinates: {{ this.lat }}, {{ this.lng }}</p>      
      <p>Geohash: {{ geohash }}</p>
      <h3>Leave a thought here</h3>
      <input type="text" v-model.trim="currentThought" @keyup.enter="send(currentThought)">
      <button v-on:click="send(currentThought)">Save</button>
    </div>
    <div id="right">
      <table>
        <tr>
          <th>Index</th>
          <th>Geohash</th>

          <th>Thought</th>
        </tr>
        <tr v-for="(item, index) in geothoughts">
          <td>{{ index }}</td>
          <td>{{ item.geohash }}</td>
          
          <td>{{ item.message }}</td>
        </tr>
      </table>
    </div>
  </div>
</template>

<script>

import axios from 'axios'
import Geohash from 'latlon-geohash'
import { grayMapStyle } from './mapStyle'
  
export default {
  name: 'app',
  data () {
    return {
      lat: "loading ...",
      lng: null,
      geohash: "loading ...",
      currentThought: "",
      geothoughts: [],
      map: null,
      currentMarker:null
    }
  },
  mounted() {
    window.addEventListener('resize', this.reloadMap);
    this.loadMap()
    this.getGeoHash()
    this.getAllGeoThoughts()
  }, 
  methods: {
    reloadMap(event) {
        this.loadMap()
        this.addMyMarkers()
    },    
    loadMap() {
        const element = document.getElementById("my-map")
        // get current location
        var hong_kong = {lat: 22.442029, lng: 114.094303};

        const mapOptions = {
            center: hong_kong,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            zoom:9,
            backgroundColor:"#eeeeee",
            panControl:false,
            zoomControl:true,
            mapTypeControl:false,
            scaleControl:false,
            streetViewControl:false,
            overviewMapControl:false,
            zoomControlOptions: {
                style:google.maps.ZoomControlStyle.SMALL
            }
        }
        this.map = new google.maps.Map(element, mapOptions);
        var mapType = new google.maps.StyledMapType(grayMapStyle, {name:"Grayscale"});    
        this.map.mapTypes.set('grey', mapType);
        this.map.setMapTypeId('grey');
        google.maps.event.addListener(this.map, 'click', this.placeMarker);
    },
    clearMarker() {
      this.currentMarker.setMap(null)
      this.currentMarker = null      
    },
    drawMarker(latLng) {
      if (!! this.currentMarker) {
        this.clearMarker()  
      }
      var icon = "https://cdn.pbrd.co/images/GZoqM3a.png";
      var marker = new google.maps.Marker({
          position: latLng,
          map: this.map,
          icon: icon
        });
        this.currentMarker = marker
    },
    placeFirstMarker(position) {
      //this.drawMarker({lat: position.coords.latitude, lng: position.coords.longitude})
      //this.currentMarker = marker
    },
    placeMarker(location) {
      // parseFloat(Math.round(num3 * 100) / 100).toFixed(2);
      this.lat = location.latLng.lat().toFixed(3)
      this.lng = location.latLng.lng().toFixed(3)
      this.drawMarker(location.latLng)
    },
    getGeoHash() {
       if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          var precision = 6
          this.geohash = Geohash.encode(position.coords.latitude, position.coords.longitude, precision);
          this.lat = position.coords.latitude.toFixed(3)
          this.lng = position.coords.longitude.toFixed(3)
          this.loadingMessage = this.geohash
          if (!this.currentMarker) {
            console.log("Placing first marker")
            this.placeFirstMarker(position)
          }
        }, (err) => {
          console.log("Error getting location: " + err)
        })
      } else {
        console.error('Cannot access geolocation')
      } 
    },
    getAllGeoThoughts() {
      axios.get(`https://413nf2l0af.execute-api.ap-northeast-1.amazonaws.com/prod/geothoughts`)
      .then(response => {
        this.geothoughts = response.data.body.geothoughts
        this.addMyMarkers()
      })
      .catch(e => {
        console.log("Error getting geothoughts: " + e)
        //this.errors.push(e)
      })
    },
    send(currentThought) {
      this.clearMarker()
      var data = {
        "lat": this.lat,
        "lng": this.lng,
        "geohash": this.geohash,
        "message": this.currentThought
      }
      axios.post(`https://413nf2l0af.execute-api.ap-northeast-1.amazonaws.com/prod/geothoughts`, data)
      .then(response => {
        this.currentThought = ""
        this.getAllGeoThoughts()
      })
      .catch(e => {
        console.log(e)
        //this.errors.push(e)
      })      
    },
    addMyMarkers() {
      var myMap = this.map
      this.geothoughts.forEach(function(geothought) {
        var marker_coords = {lat: geothought.lat, lng: geothought.lng}
        try {
          var image = 'https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png';
          var marker = new google.maps.Marker({
            position: marker_coords,
            map: myMap,
            title: geothought.message,
            icon: image,
            animation: google.maps.Animation.DROP,
          });
        }
        catch(err) {
            console.log("Error creating marker " + err)
        }
        
      });   
    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 5px;
}

h1, h2 {
  font-weight: normal;
}

table {
  text-align:left;
}
a {
  color: #42b983;
}
  
#my-map {
  height: 450px;
  width: 100%;
  background-color:beige;
}
  
#left {
  float: left;
  width: 45%;
  height:500px;
}

#right {
  float:right;
  padding:20px;
  width:50%;
  height:500px;
  border-left:1px solid indianred;
}
</style>
