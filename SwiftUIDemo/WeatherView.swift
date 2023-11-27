//
//  WeatherView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/9.
//

import SwiftUI

struct WeatherView: View {
    @State var isPresent = false
    @State var city: String = "Suzhou, China"
    @State var max: Int = 50
    @State var min: Int = -50
    @State var startColor: Color = .blue
    @State var endColor: Color = .green
    
    var body: some View {
        ZStack {
            BackgroundView(startColor: startColor, endColor: endColor)
            VStack {
                WeatherBodyView(city: city, max: max, min: min)
                Button("Update") {
                    max = Int.random(in: 0...100)
                    min = Int.random(in: -50...0)
                }.foregroundColor(.white).font(.title)
            }
        }
    }
}

struct WeatherBodyView: View {
    var city: String
    var max: Int
    var min: Int
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text(city).font(.largeTitle).foregroundColor(.white).padding()
                Image(systemName: Constants.images.randomElement()!).resizable().renderingMode(.original).frame(width: 120, height: 120).aspectRatio(contentMode: .fit).padding(.top, 20).foregroundColor(.white)
                Text("\(Int.random(in: min..<max))\(Constants.degreeSymbol)").font(.system(size: 50, weight: .medium)).foregroundColor(.white).padding()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Constants.weeks, id: \.self) { w in
                            VStack {
                                Text(w.rawValue.capitalized).font(.title).foregroundColor(.white)
                                Image(systemName: Constants.images.randomElement()!).renderingMode(.original).resizable().frame(width: 40, height: 40).foregroundColor(.white)
                                Text("\(Int.random(in: min..<max))\(Constants.degreeSymbol)").font(.system(size: 25, weight: .medium)).foregroundColor(.white)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct BackgroundView: View {
    var startColor: Color
    var endColor: Color
    
    var body: some View {
        LinearGradient(colors: [startColor, endColor], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
    }
}

#Preview {
    WeatherView()
}
