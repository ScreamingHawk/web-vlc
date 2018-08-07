// Download offline HTML
self.addEventListener('install', function(event) {
	const offlineRequest = new Request('offline.html');
	event.waitUntil(
		fetch(offlineRequest).then(function(response) {
			return caches.open('offline').then(function(cache) {
				console.log('[oninstall] Cached offline page', response.url);
				return cache.put(offlineRequest, response);
			});
		})
	);
});

// Display offline HTML when offline
self.addEventListener('fetch', function(event) {
	const request = event.request;
	if (request.method === "GET"){
		event.respondWith(
			fetch(request).catch(function(error){
				console.error('[onfetch] failed. Serving cached offline fallback ' + error);
				return caches.open('offline').then(function(cache){
					return cache.match('offline.html');
				});
			})
		);
	}
});
