//
//  LayoutDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/1/19.
//

import SwiftUI

struct LayoutDemo: View {
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Button("A") {
                    print("a...")
                }
                Button("B") {
                    print("b...")
                }
            }.background(.yellow)
        }
    }
}

#Preview {
    LayoutDemo()
}
