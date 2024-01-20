//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/10/30.
//

import SwiftUI

struct PropertyWrapperDemo: View {
    var body: some View {
        NavigationView {
            TabView {
                FormView().tabItem {
                    Image(systemName: "house")
                    Text("Form")
                }
                ListView().tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("List")
                }
            }
        }
    }
    
    struct ListView: View {
        var body: some View {
            List {
                Section(header: Text("Button works in List")) {
                    Button("Button A") { print("A...") }
                    Button("Button B") { print("B...") }
                    Button("Button C") { print("C...") }
                }
            }
        }
    }
    
    struct FormView: View {
        @StateObject private var book = Book()
        @State private var book1 = Book1()
        @State private var name = Name(text: "ricol")
        @State private var a = Data()
        @State private var b = Data()
        var body: some View {
            Form {
                Section("State on Struct") {
                    VStack(alignment: .leading) {
                        Button("Change @State name") {
                            name = Name(text: name.text + " updated.")
                        }
                        Text(name.text)
                    }
                }
                Section("Button Issues in Form") {
                    VStack(alignment: .leading, content: {
                        Button("Button A") {
                            print("a...")
                        }
                        Button("Button B") {
                            print("b...")
                        }
                        Button("Button C") {
                            print("c...")
                        }
                    })
                }
                
                Section("Change @State a.property on class") {
                    Button("Change") {
                        a.value += a.value
                        print("changed. \(a.value)")
                    }
                    Text(a.value)
                }
                
                Section("Change @State b on class") {
                    Button("Change") {
                        b = Data()
                        b.value += " updated."
                    }
                    Text(b.value)
                }
                
                Section("Reset @State b on class") {
                    Button("Rest") {
                        b = Data()
                    }
                    Text(b.value)
                }
                
                Section("@Observable") {
                    VStack(alignment: .leading) {
                        Button("update book") {
                            book.title += "changed book title"
                        }
                        BookViewForObservedObjectBook(book: book)
                    }
                }
                Section("NOObservableObject") {
                    VStack(alignment: .leading) {
                        Button("update book") {
                            book1.title += "changed book1 title"
                        }
                        BookViewWithoutObservedObject(book: book1)
                    }
                }
                Section("ObservedObject") {
                    VStack(alignment: .leading) {
                        TextField("title", text: $book.title)
                        BookTitleEditViewBindingWithObservedObject(book: book)
                    }
                }
                Section("Binding") {
                    
                }
                Section("Bindable") {
                    BookTitleEditViewWithBindable(book: book1)
                }
                Section("Navigation") {
                    NavigationLink(destination: Text("hi")) {
                        Text("Go to next view")
                    }
                }
            }
        }
        
        fileprivate class Book: ObservableObject {
            @Published var title = "A sample book"
            var isAvailable = true
        }
        
        @Observable
        fileprivate class Book1 {
            var title = "A sample book"
            var isAvailable = true
        }
        
        fileprivate struct Name {
            var text: String
        }
        
        fileprivate class Data {
            var value: String = "data"
        }
        
        fileprivate struct BookTitleEditViewBindingWithObservedObject: View {
            @ObservedObject var book: Book
            var body: some View {
                TextField("title", text: $book.title)
            }
        }
        
        fileprivate struct BookTitleEditViewWithBindable: View {
            @Bindable var book: Book1
            var body: some View {
                TextField("title", text: $book.title)
            }
        }
        
        
        fileprivate struct BookViewForObservedObjectBook: View {
            @ObservedObject var book: Book
            
            var body: some View {
                Text(book.title)
            }
        }
        
        fileprivate struct BookViewWithoutObservedObject: View {
            var book: Book1
            
            var body: some View {
                Text(book.title)
            }
        }
    }
}

#Preview {
    PropertyWrapperDemo()
}

