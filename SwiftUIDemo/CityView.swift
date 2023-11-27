//
//  CityView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/10.
//

import SwiftUI

struct Cities: View {
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

#Preview {
    Group {
        NavigationView {
            let image = Constants.images.randomElement()!
            CityDetailView(city: Constants.cities.randomElement()!, weather: image)
        }
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

#Preview {
    Cities()
}
