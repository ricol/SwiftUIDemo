//
//  TabbarDemo.swift
//  SwiftUIDemoApp
//
//  Created by ricolwang on 2024/6/12.
//

import SwiftUI

struct TabbarDemo: View {
    var body: some View {
        TabView {
            View1().tabItem { Label("View1", systemImage: "person.circle.fill") }
            View2().tabItem { Label("View2", systemImage: "person.circle.fill") }
            View3().tabItem { Label("View3", systemImage: "person.circle.fill") }
        }
    }
}

struct View1: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("View3")
                List {
                    ForEach(1..<5) { i in
                        NavigationLink {
                            DeatailsView(value: i)
                        } label: {
                            Text("Destination: \(i)")
                        }
                    }
                }
                Spacer()
                Footer()
            }.toolbar(.visible, for: .tabBar).navigationTitle("View1")
                .toolbar(content: {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Go") {
                            
                        }
                    }
                })
        }
    }
}


struct View2: View {
    var body: some View {
        Text("View2")
    }
}

struct View3: View {
    var body: some View {
        Text("View3")
    }
}

struct DeatailsView: View {
    var value: Int
    var body: some View {
            Text("\(value)").navigationTitle("Details: \(value)").toolbar(.hidden, for: .tabBar)
    }
}

struct Footer: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("Welcome to the World!")
            }
            Spacer(minLength: 60)
        }
    }
}

#Preview {
    TabbarDemo()
}
