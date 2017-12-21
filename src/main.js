import Vue from 'vue'
import App from './App.vue'

import * as VueGoogleMaps from 'vue2-google-maps'
Vue.use(VueGoogleMaps, {
  load: {
    key: 'AIzaSyDBK5wYFm-lmxYiJ8eLg4b5FhMBVDNalIs',
    libraries: 'places', // This is required if you use the Autocomplete plugin
    // OR: libraries: 'places,drawing'
    // OR: libraries: 'places,drawing,visualization'
    // (as you require)
  }
})

new Vue({
  el: '#app',
  render: h => h(App)
})
