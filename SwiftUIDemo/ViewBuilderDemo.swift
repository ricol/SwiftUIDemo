//
//  ViewBuilderDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/2/21.
//

import SwiftUI

struct ViewBuilderDemo: View {
    @State var flag: Bool = true
    var body: some View {
        VStack {
            getView(flag: flag)
        }
    }
}

func getView1(flag: Bool) -> any View {
    flag ? Button("GO") {} : Text("TEXT")
}

func getView(flag: Bool) -> some View {
    Group {
        if flag {
            Button("GO") {}
        }else {
            Text("Text")
        }
    }
}

#Preview {
    ViewBuilderDemo()
}
