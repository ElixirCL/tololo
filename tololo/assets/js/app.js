// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.LeafletMap = {
  mounted() {
    const tooltipText = this.el.dataset.tooltip;

    let map = L.map('map').setView([51.505, -0.09], 13);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    // icons
    const currentIcon = L.icon({
      iconUrl: "/images/map/motorcycle.svg",
      iconAnchor:   [24, 24], // point of the icon which will correspond to marker's location
    });
    const toIcon = L.icon({
      iconUrl: "/images/map/home.svg",
      iconAnchor:   [24, 24],
    });
    const fromIcon = L.icon({
      iconUrl: "/images/map/flatware.svg",
      iconAnchor:   [24, 24],
    });

    let currentMarker = L.marker([0, 0], {title: tooltipText, icon: currentIcon})
          .bindTooltip(tooltipText,{permanent: true, direction: 'top',offset:L.point(0, -16)})

    let has_init = false
    this.handleEvent("phx:resource_update", ({ resource }) => {
      if (has_init == false) {
        let fromMarker = L.marker(resource.from_pos, {title: resource.from_name, icon: fromIcon})
          .bindTooltip(resource.from_name, {permanent: false, direction: 'top',offset:L.point(0, -24)})
          .addTo(map)
        let toMarker = L.marker(resource.to_pos, {title: resource.to_name, icon: toIcon})
          .bindTooltip(resource.to_name, {permanent: false, direction: 'top',offset:L.point(0, -24)})
          .addTo(map)


        map.setView([
          (resource.from_pos[0] + resource.to_pos[0]) / 2,
          (resource.from_pos[1] + resource.to_pos[1]) / 2
        ], 8.5)

        has_init = true
      }

      if (resource.current_pos[0]) {
        currentMarker.setLatLng(resource.current_pos)
        map.addLayer(currentMarker)
      }
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

