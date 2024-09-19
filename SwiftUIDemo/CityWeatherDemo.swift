//
//  CityWeatherDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/10.
//

import SwiftUI

struct CityWeatherDemo: View {
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(startColor: .yellow, endColor: .orange)
                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(0...200, id: \.self) { n in
                            NavigationLink {
                                CityDetailView(city: Constants.cities.randomElement()!, weather: Constants.images.randomElement()!)
                            } label: {
                                CityView(city: Constants.cities.randomElement()!, weather: Constants.images.randomElement()!).foregroundColor(.black)
                            }
                        }
                    }
                }
            }.navigationTitle("Cities")
        }
    }
    
    struct CityView: View {
        let size: CGFloat = 50
        var city: String
        var weather: String
        var body: some View {
            VStack {
                Text(city.capitalized)
                Image(systemName: weather).resizable().renderingMode(.original).frame(width: size, height: size)
            }.padding()
        }
    }
    
    struct CityDetailView: View {
        let size: CGFloat = 100
        var city: String
        @State var weather: String
        var body: some View {
            ZStack {
                BackgroundView(startColor: .yellow, endColor: .orange)
                VStack {
                    Image(systemName: weather).resizable().renderingMode(.original).frame(width: size, height: size)
                }.padding()
            }.navigationTitle(city.capitalized).navigationBarTitleDisplayMode(.inline).toolbar(content: {
                Button("Change") {
                    weather = Constants.images.randomElement()!
                }
            })
        }
    }
    
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
    }

    struct BackgroundView: View {
        var startColor: Color
        var endColor: Color
        
        var body: some View {
            LinearGradient(colors: [startColor, endColor], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
        }
    }
}

#Preview {
    CityWeatherDemo()
}
