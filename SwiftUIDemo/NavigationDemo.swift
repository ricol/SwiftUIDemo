//
//  NavigationDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2025/6/19.
//

import SwiftUI

struct NavigationDemo1: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Show Detail View", value: "Hello") // Push with value
                NavigationLink("Show Settings", destination: SettingsView()) // Classic push
            }
            .navigationDestination(for: String.self) { value in
                DetailView(text: value) // Handles navigation with value
            }
        }
    }
    
    struct DetailView: View {
        let text: String
        
        var body: some View {
            Text("Detail View: \(text)")
                .navigationTitle("Detail")
        }
    }

    struct SettingsView: View {
        var body: some View {
            Text("Settings Screen")
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    NavigationDemo1()
}

struct NavigationDemo2: View {
    var body: some View {
        NavigationStack {
            List(1..<10) { number in
                NavigationLink("Item \(number)", value: number)
            }
            .navigationDestination(for: Int.self) { number in
                DetailView(number: number)
            }
        }
    }
    
    struct DetailView: View {
        let number: Int
        
        var body: some View {
            Text("Detail View: \(number)")
                .navigationTitle("Detail")
        }
    }
}

#Preview {
    NavigationDemo2()
}

struct NavigationDemo3: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            Button("Go to Settings") {
                path.append("settings") // Programmatic navigation
            }
            .navigationDestination(for: String.self) { value in
                if value == "settings" {
                    SettingsView()
                }
            }
        }
    }
    
    struct SettingsView: View {
        var body: some View {
            Text("Settings Screen")
                .navigationTitle("Settings")
        }
    }
}

#Preview {
    NavigationDemo3()
}

struct NavigationDemo4: View {
    @State private var path: [String] = ["dashboard", "profile", "settings"]

    var body: some View {
        NavigationStack(path: $path) {
            Text("Navigation")
                .navigationDestination(for: String.self) { screen in
                    switch screen {
                    case "dashboard": Text("dashboard")
                    case "profile": Text("profile")
                    case "settings": Text("settings")
                    default: EmptyView()
                    }
                }
        }
    }
}

#Preview {
    NavigationDemo4()
}

struct NavigationDemo5: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Show String View", value: "Hello")
                NavigationLink("Show Int View", value: 42)
            }
            .navigationDestination(for: String.self) { stringValue in
                Text("String: \(stringValue)")
            }
            .navigationDestination(for: Int.self) { intValue in
                Text("Int: \(intValue)")
            }
        }
    }
}

#Preview {
    NavigationDemo5()
}

struct NavigationDemoAllInOne: View {
    @State private var path = NavigationPath()
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Navigation Links") {
                    NavigationLink("Profile (String)", value: "profile")
                    NavigationLink("Settings (Int)", value: 1)
                    NavigationLink("Direct Push", destination: Text("Direct View"))
                }
                
                Section("Actions") {
                    Button("Programmatic Push") {
                        path.append("programmatic")
                    }
                    
                    Button("Deep Link") {
                        path.append("screen1")
                        path.append("screen2")
                    }
                }
            }
            .navigationTitle("Main Menu")
            .navigationDestination(for: String.self) { value in
                if value == "profile" {
                    Text("Profile")
                } else if value == "programmatic" {
                    Text("Programmatic View")
                } else {
                    Text("String: \(value)")
                }
            }
            .navigationDestination(for: Int.self) { value in
                Text("Int: \(value)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Help") {
                        showSheet = true
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                Text("Help Screen")
            }
        }
    }
}

#Preview {
    NavigationDemoAllInOne()
}
