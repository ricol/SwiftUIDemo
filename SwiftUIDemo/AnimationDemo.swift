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
    var body: some View {
        VStack {
            Spacer()
            Text("Hello, World!")
                .foregroundStyle(Color.white)
                .padding()
                .frame(width: size.width, height: size.height)
                .background(.blue)
                .padding()
                .background(.yellow)
                .rotationEffect(degree)
                .animation(.easeIn, value: degree)
                .animation(.easeIn, value: size.width)
                .animation(.easeIn, value: size.height)
                .rotation3DEffect(rotation, axis: (x: 0.0, y: 1.0, z: 0.0))
                .animation(.easeIn, value: rotation)
            Spacer()
            Divider()
            HStack {
                Button("Rotate") {
                    degree.degrees += 10
                }
                Button("Size") {
                    size.width += CGFloat((10...20).randomElement()!)
                    size.height += CGFloat((10...20).randomElement()!)
                }
                Button("3D Rotate") {
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
}

#Preview {
    AnimationDemo()
}
