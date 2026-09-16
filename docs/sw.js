/* Lumo Service Worker
   WICHTIG: index.html wird zuerst aus dem Netz geholt, damit eine neue Fassung
   sofort ankommt. Der Cache ist nur der Rückfall, wenn du offline bist. */
const CACHE = "lumo-v29";
const SHELL = ["./", "./index.html", "./manifest.webmanifest", "./icon-192.png", "./icon-512.png",
  "./apple-touch-icon.png", "./apple-touch-icon-180.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys()
    .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener("message", e => { if(e.data === "skipWaiting") self.skipWaiting(); });

self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  if(url.hostname.endsWith("open-meteo.com")) return;
  if(e.request.method !== "GET") return;

  const istSeite = e.request.mode === "navigate" || url.pathname.endsWith("/") ||
                   url.pathname.endsWith("index.html");
  if(istSeite){                                   // immer die neueste Fassung versuchen
    e.respondWith(
      fetch(e.request).then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put("./index.html", copy));
        return res;
      }).catch(() => caches.match("./index.html"))
    );
    return;
  }
  e.respondWith(
    caches.match(e.request).then(hit => hit || fetch(e.request).then(res => {
      if(res.ok && url.origin === location.origin){
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(e.request, copy));
      }
      return res;
    }).catch(() => caches.match("./index.html")))
  );
});
