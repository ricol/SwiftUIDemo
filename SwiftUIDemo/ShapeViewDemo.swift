//
//  ShapeViewDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/27.
//

import SwiftUI

struct ShapeViewDemo: View {
    var body: some View {
        VStack {
            Rectangle().frame(width: 100, height: 100)
            RoundedRectangle(cornerSize: CGSize(width: 100, height: 100), style: .continuous).stroke(style: StrokeStyle(lineWidth: 2)).frame(width: 200, height: 200)
        }
    }
}

#Preview {
    ShapeViewDemo()
}
