const ZOOM_KEY = 'levelup_zoom';

export function saveZoom() {
  const zoom = window.devicePixelRatio || 1;
  localStorage.setItem(ZOOM_KEY, zoom.toString());
}

export function loadZoom() {
  const savedZoom = localStorage.getItem(ZOOM_KEY);
  if (savedZoom) {
    const zoomValue = parseFloat(savedZoom);
    if (!isNaN(zoomValue) && zoomValue > 0) {
      document.body.style.zoom = zoomValue;
    }
  }
}

export function initZoomManager() {
  loadZoom();
  
  window.addEventListener('resize', () => {
    saveZoom();
  });

  window.addEventListener('beforeunload', () => {
    saveZoom();
  });
}
