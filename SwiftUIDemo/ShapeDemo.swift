//
//  ShapeDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/1/31.
//

import SwiftUI

struct Html: Codable {
    var content: String
}

struct Person {
    var name: String
}

struct Name: Encodable, Decodable {
    var content: String
    var extra: String
}

struct ShapeDemo: View {
    @State var h: CGFloat = 0
    @State var startLocation: CGPoint = CGPoint.zero
    @State var translation: CGSize = CGSize.zero
    @State var content: String = ""
    var body: some View {
        v
    }
    
    var v: some View {
        VStack {
            HStack {
                Button("Test") {
                    let h = Html(content: "welcome to swift world")
                    do {
                        let data = try JSONEncoder().encode(h)
                        print("encoded data: \(data)")
                        let json = try JSONSerialization.jsonObject(with: data)
                        print("json: \(json)")
                        do {
                            let parsed = try JSONDecoder().decode(Html.self, from: data)
                            print("parsed as Html: \(parsed.content)")
                        }catch let e {
                            print("decode error: \(e)")
                        }
                        do {
                            let parsed = try JSONDecoder().decode(Name.self, from: data)
                            print("parsed as Name: \(parsed.content)")
                        }catch let e {
                            print("decode error: \(e)")
                        }
                    }catch let e {
                        print("encode error: \(e)")
                    }
                }
                Button("GO") {
                    content = ""
                    print("running...")
                    let url = URL(string: "https://www.baidu.com")!
                    let request = URLRequest(url: url)
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        print("returned.")
                        if let data {
                            if let s = String(data: data, encoding: .utf8) {
                                print("parsed.")
                                DispatchQueue.main.async {
                                    content = ".utf8\n" + s
                                    print("complete.")
                                }
                            }
                        }
                    }.resume()
                }
                Button("AWAIT") {
                    content = ""
                    let url = URL(string: "https://www.baidu.com")!
                    Task {
                        print("await...")
                        let (data, response) = try await URLSession.shared.data(from: url)
                        print("returned.")
                        if let object = try? JSONDecoder().decode(Html.self, from: data) {
                            print("object: \(object)")
                        }
                        do {
                            let object = try JSONDecoder().decode(Html.self, from: data)
                            print("object: \(object)")
                        }catch let e {
                            print("error: \(e)")
                        }
                        if let s = String(data: data, encoding: .utf8) {
                            print("parsed.")
                            DispatchQueue.main.async {
                                content = ".utf8\n" + s
                                print("complete.")
                            }
                        }
                        print("done.")
                    }
                }
            }
            ScrollView(.vertical) {
                Text(content)
            }
        }
    }
    
    func mainView() -> some View {
        VStack {
            HStack {
                Button("Test") {
                    let h = Html(content: "welcome to swift world")
                    do {
                        let data = try JSONEncoder().encode(h)
                        print("encoded data: \(data)")
                        do {
                            let parsed = try JSONDecoder().decode(Html.self, from: data)
                            print("parsed as Html: \(parsed.content)")
                        }catch let e {
                            print("decode error: \(e)")
                        }
                        do {
                            let parsed = try JSONDecoder().decode(Name.self, from: data)
                            print("parsed as Name: \(parsed.content)")
                        }catch let e {
                            print("decode error: \(e)")
                        }
                    }catch let e {
                        print("encode error: \(e)")
                    }
                }
                Button("GO") {
                    content = ""
                    print("running...")
                    let url = URL(string: "https://www.baidu.com")!
                    let request = URLRequest(url: url)
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        print("returned.")
                        if let data {
                            if let s = String(data: data, encoding: .utf8) {
                                print("parsed.")
                                DispatchQueue.main.async {
                                    content = ".utf8\n" + s
                                    print("complete.")
                                }
                            }
                        }
                    }.resume()
                }
                Button("AWAIT") {
                    content = ""
                    let url = URL(string: "https://www.baidu.com")!
                    Task {
                        print("await...")
                        let (data, response) = try await URLSession.shared.data(from: url)
                        print("returned.")
                        if let object = try? JSONDecoder().decode(Html.self, from: data) {
                            print("object: \(object)")
                        }
                        do {
                            let object = try JSONDecoder().decode(Html.self, from: data)
                            print("object: \(object)")
                        }catch let e {
                            print("error: \(e)")
                        }
                        if let s = String(data: data, encoding: .utf8) {
                            print("parsed.")
                            DispatchQueue.main.async {
                                content = ".utf8\n" + s
                                print("complete.")
                            }
                        }
                        print("done.")
                    }
                }
            }
            ScrollView(.vertical) {
                Text(content)
            }
        }
    }
}

#Preview {
    ShapeDemo()
}
