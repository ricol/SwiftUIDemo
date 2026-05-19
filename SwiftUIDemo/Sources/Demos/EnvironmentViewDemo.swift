//
//  EnvironmentViewDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2025/11/18.
//

import SwiftUI

@Observable
class Store {
    var data: String = "environment data demo"
}

struct EnvironmentViewDemo: View {
    @Environment(Store.self) var store // Inject through environment in view
    var body: some View {
        VStack {
            Text(store.data)
            Button("update") {
                store.data = "environment data updated"
            }
        }
    }
}

#Preview {
    EnvironmentViewDemo().environment(Store())
}

struct StoreKey: EnvironmentKey {
    static var defaultValue = Store()
}

extension EnvironmentValues {
    var store: Store {
        get { self[StoreKey.self] }
        set { self[StoreKey.self] = newValue }
    }
}

struct EnvironmentViewDemo1: View {
    @Environment(\.store) var store // Inject through environment in view
    var body: some View {
        VStack {
            Text(store.data)
            Button("update") {
                store.data = "environment data updated"
            }
        }
    }
}

#Preview {
    EnvironmentViewDemo1()
}
