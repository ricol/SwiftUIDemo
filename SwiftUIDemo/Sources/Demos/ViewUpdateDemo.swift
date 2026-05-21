//
//  ViewUpdateDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/3/23.
//

import SwiftUI

struct Student {
    var name: String
    var age: Int
    var height: Double = 0
    var weight: Double = 0

    func sayHello() {
        print("Hello, I'm \(name)")
    }

    var bmi: Double {
        weight / (height * height)
    }
}

extension Student: View {
    var body: some View {
        Text("Hello, I'm \(name), \(age) years old")
    }
}

enum EnumView: View {
    case hello
    var body: some View {
        Text("\(self)")
    }
}

#Preview {
    Student(name: "ricol", age: 0, height: 70, weight: 70)
}

#Preview {
    EnumView.hello
}

let emojis = ["😀", "😬", "😄", "🙂", "😗", "🤓", "😏", "😕", "😟", "😎", "😜", "😍", "🤪"]

struct EmojiDemo: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { timeline in
            HStack(spacing: 120) {
                let randomEmoji = emojis.randomElement() ?? ""
                Text(randomEmoji)
                    .font(.largeTitle)
                    .scaleEffect(4.0)

                RightEmoji()
            }
        }
    }

    struct RightEmoji: View {
        // let id: Int = .random(in: 0 ... 100_000) // Uncommenting this line makes the emoji update
        var body: some View {
            let randomEmoji = emojis.randomElement() ?? ""

            Text(randomEmoji)
                .font(.largeTitle)
                .scaleEffect(4.0)
        }
    }
}

#Preview {
    EmojiDemo()
}

struct OnTapDemo: View {
    @State var count = 0
    var body: some View {
        let _ = print("Evaluating View Declaration Value")
        Text("Count: \(count)")
        Text("Tap Me")
            .onTapGesture {
                count += 1
            }
        SubView1()
        SubView2(count: count)
    }
}

struct SubView1: View {
    init() {
        print("SubView1 init")
    }

    var body: some View {
        let _ = print("SubView1 body update")
        Text("No changes")
    }
}

struct SubView2: View {
    let count: Int
    init(count: Int) {
        self.count = count
        print("SubView2 init")
    }

    var body: some View {
        let _ = print("subview2 body update")
        Text("Count Changes: \(count)")
    }
}

#Preview {
    OnTapDemo()
}
