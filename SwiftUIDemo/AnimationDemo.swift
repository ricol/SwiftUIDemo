//
//  AnimationDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/23.
//

import SwiftUI

struct AnimationDemo: View {
    @State var degree: Angle = Angle(degrees: 0)
    @State var size: CGSize = CGSize(width: 100, height: 100)
    @State var rotation: Angle = Angle(degrees: 0)
    @State var isOn: Bool = false
    var body: some View {
        Form {
            Section("Symbol effect") {
                HStack {
                    Text("Symbol effect: ")
                    Image(systemName: "wifi").symbolEffect(.variableColor.reversing)
                    Image(systemName: "bolt.slash.fill").symbolEffect(.pulse)
                    Image(systemName: "folder.fill.badge.person.crop").symbolEffect(.pulse)
                    // Add an effect in SwiftUI.
                    Image(systemName: "globe")
                        // Add effect with discrete behavior to image view.
                        .symbolEffect(.pulse, options: .repeat(3))
                    Image(systemName: "globe")
                        // Add effect with indefinite behavior to image view.
                        .symbolEffect(.pulse)
                }
            }
            Section("View Animation") {
                VStack {
                    Text("Hello, World!")
                        .foregroundStyle(Color.white)
                        .padding()
                        .frame(width: size.width, height: size.height)
                        .background(.blue)
                        .padding()
                        .background(.yellow)
                        .rotationEffect(degree)
                        .animation(.spring(.snappy, blendDuration: 2), value: degree)
                        .animation(.easeIn, value: size.width)
                        .animation(.easeIn, value: size.height)
                        .rotation3DEffect(rotation, axis: (x: 0.0, y: 1.0, z: 0.0))
                        .animation(.easeIn, value: rotation)
                    Divider()
                    HStack {
                        Button("Rotate") {
                            degree.degrees += 50
                        }
                        Button("Size") {
                            size.width += CGFloat((10...20).randomElement()!)
                            size.height += CGFloat((10...20).randomElement()!)
                        }
                        Button("3D") {
                            rotation.degrees += 10
                        }
                        Button("Reset") {
                            degree.degrees = 0
                            rotation.degrees = 0
                            size.width = 100
                            size.height = 100
                        }
                    }.buttonStyle(.borderedProminent)
                }
            }
            Section("Sprints Animation") {
                VStack {
                    Toggle(isOn: $isOn, label: {
                        Text("Toggle")
                    })
                }
            }
        }
    }
}

#Preview {
    AnimationDemo()
}

struct CustomProgressIndicator: View {
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20.0)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut(duration: 0.4), value: 2.0)
                }
                .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                Spacer()
                Button("run") {
                    withAnimation {
                        progress = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1].randomElement()!
                    }
                }
            }
        }
    }
}

#Preview {
    CustomProgressIndicator()
}
