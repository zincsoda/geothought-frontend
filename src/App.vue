<template>
  
  <div id="app">
    <div id="map"></div>
    <div id="left">
      <h3>Geohash: {{ loadingMessage }}</h3>
      <h3>Coordinates: {{ coordinates }}</h3>
      <h3>Current Thought: {{ currentThought }}</h3>

      <input type="text" v-model.trim="messageInput" @keyup.enter="send(messageInput)">
      <button v-on:click="send(messageInput)">Save</button>
    </div>
    <div id="right">
      <table>
        <tr v-for="(item, index) in geothoughts">
          <td>{{ index }} | {{ item.geohash }} | {{ item.coordinates }} | {{ item.message }}</td>
        </tr>
      </table>
    </div>
  </div>
</template>

<script>

import axios from 'axios'
import Geohash from 'latlon-geohash'
import GoogleMapsLoader from 'google-maps'

export default {
  name: 'app',
  data () {
    return {
      messageInput: "",
      coordinates: "loading ...",
      geohash: "loading ...",
      currentThought: "<empty>",
      geothoughts: []
    }
  },
  mounted() {
    //this.db = "https://9ujv6aedjk.execute-api.us-east-1.amazonaws.com/prod/geothought"
    this.getGeoHash()
    this.getAllGeoThoughts()
    
    GoogleMapsLoader.load(function(google) {
      new google.maps.Map(el, options)
    })
  }, 
  methods: {
    getGeoHash() {
       if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          var precision = 5
          this.geohash = Geohash.encode(position.coords.latitude, position.coords.longitude, precision);
          this.coordinates = position.coords.latitude + ", " + position.coords.longitude
          this.loadingMessage = this.geohash
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
      })
      .catch(e => {
        console.log("Error getting geothoughts: " + e)
        this.errors.push(e)
      })
    },
    send(messageInput) {
      console.log(messageInput)
      this.currentThought = messageInput
      var data = {
        "coordinates": this.coordinates,
        "geohash": this.geohash,
        "message": this.currentThought
      }
      console.log(data)
      axios.post(`https://413nf2l0af.execute-api.ap-northeast-1.amazonaws.com/prod/geothoughts`, data)
      .then(response => {
        this.getAllGeoThoughts()
      })
      .catch(e => {
        this.errors.push(e)
      })      
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
  
#map {
  height: 500px;
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
  width:50%;
  height:500px;
  border-left:1px solid indianred;
}
</style>
