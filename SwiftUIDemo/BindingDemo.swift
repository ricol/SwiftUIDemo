//
//  BindingDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2025/6/19.
//

import SwiftUI

struct BindingDemo: View {
    @State private var score: Int = 0
    @State private var newScore: Int = 0
    
    var body: some View {
        let binding = Binding {
            newScore
        } set: { newValue in
            newScore = max(0, newValue)
        }
        VStack(alignment: .center) {
            Stepper("Score: \(score) with $score", value: $score)
            Stepper("Score: \(binding.wrappedValue) with manual binding", value: binding)
        }
    }
}

#Preview {
    BindingDemo()
}
