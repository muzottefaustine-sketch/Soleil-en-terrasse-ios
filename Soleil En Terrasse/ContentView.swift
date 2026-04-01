import SwiftUI
import WebKit
struct WebView: UIViewRepresentable {
let url: URL
func makeCoordinator() -> Coordinator { Coordinator() }
func makeUIView(context: Context) -> WKWebView {
let config = WKWebViewConfiguration()
let wv = WKWebView(frame: .zero, configuration: config)
wv.load(URLRequest(url: url))
return wv
}
func updateUIView(_ wv: WKWebView, context: Context) {}
class Coordinator: NSObject, WKNavigationDelegate {}
}
struct ContentView: View {
let appURL = URL(string: "https://soleil-bordeaux.vercel.app")!
var body: some View {
WebView(url: appURL)
.ignoresSafeArea()
}
}

#Preview {
ContentView()
}
