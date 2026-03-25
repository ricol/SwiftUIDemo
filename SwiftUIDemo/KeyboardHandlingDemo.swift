//
//  KeyboardHandlingDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/3/25.
//

import SwiftUI

struct KeyboardHandlingDemo: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.linearGradient(.init(colors: [.red, .blue, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea(.all) // Only let the background ignore the safe area
            VStack {
                Circle().fill(.regularMaterial).frame(width: 100, height: 100).padding(.vertical, 100)
                TextField("name", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
        }
    }
}

#Preview {
    KeyboardHandlingDemo()
}
