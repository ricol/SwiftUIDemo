//
//  constants.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/16.
//

import SwiftUI

struct Constants {
    enum WeekDay: String {
        case mon, tue, wed, thu, fri, sat, sun
    }
    static let weeks: [WeekDay] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]
    static let images: [String] = ["cloud.sun.fill", "sun.max.fill", 
                                   "wind", "cloud.snow",
                                   "cloud.snow.fill", "cloud.bolt.rain.fill",
                                   "cloud.fog.fill", "cloud.rain.fill",
                                   "cloud.sun", "sun.max",
                                   "wind.snow", "snowflake"]
    static let degreeSymbol = "°"
    static let colors: [Color] = [.red, .blue, .green, .orange, .cyan, .brown]
    static let allColors: [Color] = [.red, .blue, .yellow, .green, .brown, .purple, .cyan, .indigo, .mint, .pink]
    static let cities = ["su zhou", "chang sha", "bei jing", "he fei", "nan jing", "shang hai", "hang zhou"]
    static let urls = ["https://www.baidu.com",
                "https://www.bing.com",
                "https//www.163.com",
                "https://www.sohu.com",
                "https://www.china.com",
                "https://www.qq.com"]
    static let PI: CGFloat = 3.1415216
    static let liusisi: [UIImage] = {
        var result = [UIImage]()
        if let path = Bundle.main.path(forResource: "liusisi", ofType: "bundle"), let bundle = Bundle(path: path)  {
            if let contents = try? FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil) {
                for c in contents {
                    if let image = UIImage(named: c.lastPathComponent, in: bundle, with: nil) {
                        result.append(image)
                    }
                }
            }
        }
        return result
    }()
}
