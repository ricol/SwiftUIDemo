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
        VStack {
            HStack {
                Button("EncodeDecode") {
                    content = ""
                    let h = Html(content: "welcome to swift world")
                    do {
                        let data = try JSONEncoder().encode(h)
                        content = "encoded data: \(data)"
                        let json = try JSONSerialization.jsonObject(with: data)
                        content += "\njson: \(json)"
                        do {
                            let parsed = try JSONDecoder().decode(Html.self, from: data)
                            content += "\nparsed as Html: \(parsed.content)"
                        }catch let e {
                            content += "\ndecode error: \(e)"
                        }
                        do {
                            let parsed = try JSONDecoder().decode(Name.self, from: data)
                            content += "\nparsed as Name: \(parsed.content)"
                        }catch let e {
                            content += "\ndecode error: \(e)"
                        }
                    }catch let e {
                        content += "\nencode error: \(e)"
                    }
                }
                Button("GO") {
                    content = ""
                    print("running...")
                    let s = "webcal://bells-dem.opensimsim.com/v3/ical/37886794d733fb3f86f09f5719baceed88de1d40eb74e6be2a7670d295b70f0430ad3e5aaa78dbcea17fbb80b77202bce410e80423ce9cb084a65a85bed9eba9544248f8aabe5846"
                    let data = s.components(separatedBy: "webcal:")
                    let u = "https:" + data.last!
                    let url = URL(string: u)!
                    let request = URLRequest(url: url)
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        print("returned.")
                        if let data {
                            if let s = String(data: data, encoding: .utf8) {
                                print("parsed.")
                                let data = s.components(separatedBy: "\n")
                                for record in data {
                                    let components = record.components(separatedBy: ":")
                                    if components.count >= 2 {
                                        if let k = components.first, let v = components.last, k == "X-WR-CALNAME" {
                                            content += "CALNAME: " + v
                                            break
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    content += "\n.utf8\n" + s
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
