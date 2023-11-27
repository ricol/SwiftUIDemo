//
//  ActivityIndicatorView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/13.
//

import SwiftUI

struct ActivityView: View {
    @State private var isShowing = false
    var body: some View {
        VStack(spacing: 20) {
            ActivityIndicatorView(isShowing: isShowing, color: .red)
            Button(isShowing ? "Stop" : "Start") {
                isShowing.toggle()
            }
            Button("welcome") {
                
            }.frame(width: 100, height: 40).background(.blue).cornerRadius(10).shadow(color: .red, radius: 10).foregroundColor(.white).font(.title2)
        }
    }
}

struct MetroView: View {
    @State private var update = false
    var body: some View {
        NavigationView {
            ZStack {
//                BGView()
                ScrollView(.vertical) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center, content: {
                        ForEach(0..<100, id: \.self) { _ in
                            SimpleFlipper()
                        }
                    })
                }.navigationTitle("Metro").padding().toolbar(content: {
                })
            }
        }
    }
}

let allColors: [Color] = [.red, .blue, .yellow, .green, .brown, .purple, .cyan, .indigo, .mint, .pink]

struct BGView: View {
    @State private var start: Color = allColors.randomElement()!
    @State private var end: Color = allColors.randomElement()!
    var body: some View {
        LinearGradient(colors: [start, end], startPoint: .top, endPoint: .bottom).ignoresSafeArea().onTapGesture {
            start = allColors.randomElement()!
            end = allColors.randomElement()!
        }
    }
}



struct Tile: View {
    @State private var isReverted = false
    let size: CGFloat = 170
    @State private var angle: CGFloat = 0
    var body: some View {
        Text("Tile").frame(width: size, height: size).background(allColors.randomElement()!).onTapGesture {
            isReverted.toggle()
            angle = isReverted ? 30 : 0
        }.animation(.default) { v in
            v.transformEffect(.init(rotationAngle: angle))
        }
    }
}

struct SimpleFlipper : View {
    @State var flipped = false
    var body: some View {
        let flipDegrees = flipped ? 180.0 : 0
        VStack {
              Spacer()
              ZStack() {
                  Text("Front").placedOnCard(allColors.randomElement()!)
                      .flipRotate(flipDegrees)
                      .opacity(flipped ? 0.0 : 1.0)
                  Text("Back").placedOnCard(allColors.randomElement()!)
                      .flipRotate(-180 + flipDegrees)
                      .opacity(flipped ? 1.0 : 0.0)
              }.animation(.easeOut(duration: 0.4))
              .onTapGesture { self.flipped.toggle() }
              Spacer()
        }
    }
}

extension View {
      func flipRotate(_ degrees : Double) -> some View {
            return rotation3DEffect(Angle(degrees: degrees), axis: (x: 0.0, y: 1.0, z: 0.0))
      }
      func placedOnCard(_ color: Color) -> some View {
            return padding(5).frame(width: 170, height: 170, alignment: .center).background(color)
      }
}

#Preview {
    MetroView()
}
