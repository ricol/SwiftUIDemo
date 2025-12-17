//
//  BindingDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2025/6/19.
//

import SwiftUI

@Observable
class Book: Identifiable {
    var title = "Sample Book Title"
    var isAvailable = true
}

struct BookEditView: View {
    @Bindable var book: Book
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text(book.title)
            Text("\(book.isAvailable ? "Available": "Not Available")")
            Form {
                TextField("Title", text: $book.title)
                Toggle("Book is available", isOn: $book.isAvailable)
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let b = Book()
    BookEditView(book: b)
}

struct LibraryView: View {
    @State private var books = [Book(), Book(), Book()]
    var body: some View {
        VStack {
            ForEach(books) { book in
                Text(book.title)
            }
            List(books) { book in
                @Bindable var book = book
                TextField("Title", text: $book.title)
            }
        }
    }
}

#Preview {
    LibraryView()
}

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

struct CustomBindingView: View {
    @StateObject var a = A()
    
    var body: some View {
        let binding = Binding<String>(
            get: { a.name },
            set: { a.name = $0 }
        )
        
        VStack(alignment: .leading) {
            Text("Your input: " + binding.wrappedValue)
            TextField("input:", text: binding)
        }.padding()
    }

    class A: ObservableObject {
        @Published var name: String = ""
    }
}

#Preview {
    CustomBindingView()
}
