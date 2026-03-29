String stripUrl(String url) {
  url = url.endsWith("/") ? url.substring(0, url.length - 1) : url;
  return url;
}
