import SwiftUI
import WebKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        manager.stopUpdatingLocation()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isOffline: Bool
    @ObservedObject var locationManager: LocationManager

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.webView = wv
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ wv: WKWebView, context: Context) {
        if let loc = locationManager.location {
            let js = "if(window._nativeGeoCallback){window._nativeGeoCallback(\(loc.coordinate.latitude),\(loc.coordinate.longitude));}"
            wv.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var webView: WKWebView?
        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorNetworkConnectionLost {
                DispatchQueue.main.async { self.parent.isOffline = true }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isOffline = false }
        }
    }
}

struct OfflineView: View {
    var onRetry: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.slash")
                .​​​​​​​​​​​​​​​​
