//
//  NavigationDemoView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/14.
//

import SwiftUI
import WebKit

func access(url: String) async -> String? {
    let url = URL(string: url)!
    var result: String? = nil
    let request = URLRequest(url: url)
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        if let res = response as? HTTPURLResponse {
            if res.statusCode == 200 {
                result = String(data: data, encoding: .utf8)
            }
        }
    } catch  {
    }
    
    return result
}

typealias TVoid = () -> Void
typealias TErrorVoid = (Error) -> Void

struct WebView: UIViewRepresentable {
    var url: String?
    var html: String?
    var delegate: WebViewDelegate = WebViewDelegate()
    var onStart: TVoid?
    var onFinished: TVoid?
    var onError: TErrorVoid?
    
    func makeUIView(context: Context) -> WKWebView {
        let w = WKWebView()
        w.navigationDelegate = delegate
        delegate.onStart = onStart
        delegate.onFinished = onFinished
        delegate.onError = onError
        return w
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let html {
            print("loading html...\(html)")
            var s: URL? = nil
            if let url = url {
                s = URL(string: url)
            }
            uiView.navigationDelegate = nil
            uiView.loadHTMLString(html, baseURL: s)
            print("end loading html.")
        }else if let url {
            print("loading url...")
            uiView.navigationDelegate = delegate
            uiView.load(URLRequest(url: URL(string: url)!))
            print("end loading url.")
        }
    }
    
    typealias UIViewType = WKWebView
    
    class WebViewDelegate: NSObject, WKNavigationDelegate {
        var onStart: TVoid?
        var onFinished: TVoid?
        var onError: TErrorVoid?
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("webView...finished.")
            onFinished?()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("webView...didFail.")
            onError?(error)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("webView...didStartProvisionalNavigation.")
            onStart?()
        }
    }
}

struct URLContentView: View {
    var URL: String?
    @State var content: String?
    @State var isLoading = false
    var body: some View {
        VStack {
            ZStack {
                if let content, content.count > 0 {
                    MyHtmlWebView(html: content, url: URL, isShowing: isLoading)
                }else if !isLoading {
                    Text("Empty!")
                }
                ActivityIndicatorView(isShowing: isLoading, color: .blue)
            }
        }.task {
            isLoading = true
            let t = Task.detached {
                let v = await access(url: URL!)
                return v
            }
            content = await t.value
            isLoading = false
        }.navigationTitle("Content")
    }
}

struct MyWebView: View {
    var url: String?
    @State var isShowing: Bool = false
    var body: some View {
        WebView(url: url, onStart: {
            isShowing = true
        }, onFinished: {
            isShowing = false
        }, onError: { e in
            isShowing = false
        }).navigationTitle("Web").toolbar(content: {
            ActivityIndicatorView(isShowing: isShowing, color: .black)
        })
    }
}

struct MyHtmlWebView: View {
    var html: String?
    var url: String?
    @State var isShowing: Bool = false
    var body: some View {
        WebView(url: url, html: html, onStart: { isShowing = true }, onFinished: { isShowing = false }, onError: {_ in isShowing = false }).navigationTitle("HTML").toolbar(content: {
            ActivityIndicatorView(isShowing: isShowing, color: .black)
        })
    }
}

struct WebViewDemo: View {
    @State var data: String?
    @State var urls = ["https://www.baidu.com",
                       "https://www.bing.com",
                       "https//www.163.com",
                       "https://www.sohu.com",
                       "https://www.china.com",
                        "https://www.qq.com"]
    var body: some View {
        NavigationStack {
            if urls.count > 0 {
                List {
                    ForEach(urls, id: \.self) { url in
                        //                    NavigationLink(url) {
                        //                        URLContentView(URL: url)
                        ////                        MyWebView(url: url)
                        //                    }
                        NavigationLink {
                            URLContentView(URL: url)
                        } label: {
                            VStack {
                                Spacer()
                                HStack(alignment: .center) {
                                    Text(url)
                                    Spacer()
                                    Image(systemName: "safari.fill")
                                }
                                Spacer()
                            }
                        }.frame(height: 50)
                            .swipeActions() {
                                HStack {
                                    Button("Delete") {
                                        if let index = urls.firstIndex(of: url) {
                                            urls.remove(at: index)
                                        }
                                    }
                                    NavigationLink("Go") {
                                        MyWebView(url: url)
                                    }
                                }
                            }
                    }
                }
            } else {
                Text("Empty")
            }
        }
    }
}

#Preview {
    WebViewDemo()
}
