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
    let map = L.map('map').setView([51.505, -0.09], 13);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    let currentMarker = L.marker([0, 0], {title: "Current"})
          .bindTooltip("Current",{permanent: false, direction: 'top',offset:L.point(-14, -5)})
          .addTo(map)

    let has_init = false
    this.handleEvent("phx:resource_update", ({ resource }) => {
      if (has_init == false) {
        let fromMarker = L.marker(resource.from_pos, {title: resource.from_name})
          .bindTooltip(resource.from_name, {permanent: false, direction: 'top',offset:L.point(-14, -5)})
          .addTo(map)
        let toMarker = L.marker(resource.to_pos, {title: resource.to_name})
          .bindTooltip(resource.to_name, {permanent: false, direction: 'top',offset:L.point(-14, -5)})
          .addTo(map)

        map.setView([
          (resource.from_pos[0] + resource.to_pos[0]) / 2,
          (resource.from_pos[1] + resource.to_pos[1]) / 2
        ], 8.5)

        has_init = true
      }

      currentMarker.setLatLng(resource.current_pos)
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

