//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/10/30.
//

import SwiftUI

struct PropertyWrapperDemo: View {
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
            Section("State on Class") {
                VStack(alignment: .leading) {
                    Button("Change @State a.property") {
                        a.value += a.value
                    }
                    Text(a.value)
                    Divider()
                    Button("Change @State b") {
                        let old = b
                        b = Data()
                        b.value += old.value
                    }
                    Text(b.value)
                }
            }
            Section("@Observable") {
                VStack(alignment: .leading) {
                    Button("update book") {
                        book.title = "changed book title"
                    }
                    BookView(book: book)
                }
            }
            Section("ObservableObject") {
                VStack(alignment: .leading) {
                    Button("update book") {
                        book1.title = "changed book1 title"
                    }
                    BookView1(book: book1)
                }
            }
            Section("ObservedObject") {
                VStack(alignment: .leading) {
                    TextField("title", text: $book.title)
                    BookTitleEditViewBinding(book: book)
                }
            }
            Section("Binding") {
                
            }
            Section("Bindable") {
                BookTitleEditView(book: book1)
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
    
    fileprivate struct BookTitleEditViewBinding: View {
        @ObservedObject var book: Book
        var body: some View {
                TextField("title", text: $book.title)
        }
    }

    fileprivate struct BookTitleEditView: View {
        @Bindable var book: Book1
        var body: some View {
                TextField("title", text: $book.title)
        }
    }


    fileprivate struct BookView: View {
        @ObservedObject var book: Book

        var body: some View {
            Text(book.title)
        }
    }

    fileprivate struct BookView1: View {
         var book: Book1

        var body: some View {
            Text(book.title)
        }
    }
}

#Preview {
    PropertyWrapperDemo()
}
