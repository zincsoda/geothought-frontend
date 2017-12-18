<template>
  <div id="app">
    <img src="./assets/logo.png">
    <h1>{{ loadingMessage }}</h1>
    
    <input type="text" v-model.trim="messageInput" @keyup.enter="send(messageInput)">
    <button v-on:click="send(messageInput)">Save</button>
  </div>
</template>

<script>

import Geohash from 'latlon-geohash'
import axios from 'axios'
  
export default {
  name: 'app',
  data () {
    return {
      messageInput: "",
      precision: 6,
      loadingMessage: "Getting Geohash ...",
      coordinates: "",
      geohash: "",
      currentThought: "",
      geothoughts: []
    }
  },
  mounted() {
    //this.db = "https://9ujv6aedjk.execute-api.us-east-1.amazonaws.com/prod/geothought"
    this.getGeoHash()
    this.getAllGeoThoughts()
  }, 
  methods: {
    getGeoHash() {
       if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          this.geohash = Geohash.encode(position.coords.latitude, position.coords.longitude, this.precision);
          this.coordinates = position.coords.latitude + ", " + position.coords.longitude
          this.loadingMessage = this.geohash
        }, (err) => {
          // error handling here
        })
      } else {
        console.error('Cannot access geolocation')
      } 
    },
    getAllGeoThoughts() {
      axios.get(`https://9ujv6aedjk.execute-api.us-east-1.amazonaws.com/prod/geothought`)
      .then(response => {
        this.thoughts = response.data
        console.log(this.thoughts)
      })
      .catch(e => {
        this.errors.push(e)
      })
    },
    send(messageInput) {
      console.log(messageInput)
      this.currentThought = messageInput
      var d = {
        "coordinates": this.coordinates,
        "geohash": this.geohash,
        "currentThought": this.currentThought
      }
      console.log(d)
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
  margin-top: 60px;
}

h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
