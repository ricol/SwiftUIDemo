//
//  ImproveViewUpdateDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/5/20.
//

import SwiftUI

struct ViewUpdateDemoGood {

    struct RootView: View {
        @State var student = Student(name: "fat", age: 88)
        var body: some View {
            VStack {
                StudentNameView(student: student)
                StudentAgeView(student: student)
                Button("random age") {
                    student.age = Int.random(in: 0...99)
                }
            }
        }
    }

    struct StudentNameView: View, Equatable {
        let student: Student
        var body: some View {
            let _ = Self._printChanges()
            Text(student.name)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.student.name == rhs.student.name
        }
    }

    struct StudentAgeView: View, Equatable {
        let student: Student
        var body: some View {
            let _ = Self._printChanges()
            Text(student.age, format: .number)
        }

        static func== (lhs: Self, rhs: Self) -> Bool {
            lhs.student.age == rhs.student.age
        }
    }

}

struct ViewUpdateDemoBad {
    struct RootView: View {
        @State var student = Student(name: "fat", age: 88)
        var body: some View {
            VStack {
                StudentNameView(student: student)
                StudentAgeView(student: student)
                Button("random age") {
                    student.age = Int.random(in: 0...99)
                }
            }
        }
    }

    struct StudentNameView: View {
        let student: Student
        var body: some View {
            let _ = Self._printChanges()
            Text(student.name)
        }
    }

    struct StudentAgeView: View {
        let student: Student
        var body: some View {
            let _ = Self._printChanges()
            Text(student.age, format: .number)
        }
    }
}

struct ViewUpdateDemoVM {
    @Observable
    class ViewModel {
        var student = Student(name: "fat", age: 88)
    }

    class ViewModelOld: ObservableObject {
        @Published var student = Student(name: "fat", age: 88)
    }

    struct RootView: View {
        @StateObject var vm = ViewModelOld()
        var body: some View {
            VStack {
                StudentNameView(vm: vm)
                StudentAgeView(vm: vm)
                Button("random age") {
                    vm.student.age = Int.random(in: 0...99)
                }
            }
        }
    }

    struct StudentNameView: View {
        @ObservedObject var vm: ViewModelOld
        var body: some View {
            let _ = Self._printChanges()
            Text(vm.student.name)
        }
    }

    struct StudentAgeView: View {
        @ObservedObject var vm: ViewModelOld
        var body: some View {
            let _ = Self._printChanges()
            Text(vm.student.age, format: .number)
        }
    }
}

struct ImproveViewUpdateDemo: View {
    var body: some View {
        List {
            Section("Bad") {
                ViewUpdateDemoBad.RootView()
            }
            Section("Good") {
                ViewUpdateDemoGood.RootView()
            }
            Section("ViewModel") {
                ViewUpdateDemoVM.RootView()
            }
        }
    }
}

#Preview {
    ImproveViewUpdateDemo()
}

struct EventSourceTest: View {
    @State private var enable = false

    var body: some View {
        VStack {
            let _ = Self._printChanges()
            Button(enable ? "Stop" : "Start") {
                enable.toggle()
            }
            TimeView(enable: enable) // A separate view, onReceive can only cause TimeView to update
        }
    }
}

struct TimeView:View{
    let enable:Bool
    @State private var timestamp = Date.now
    var body: some View{
        let _ = Self._printChanges()
        Text(timestamp, format: .dateTime.hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits).second(.twoDigits))
            .background(
                Group {
                    if enable { // Load the trigger only when necessary
                        Color.clear
                            .task {
                                while !Task.isCancelled {
                                    try? await Task.sleep(nanoseconds: 1000000000)
                                    NotificationCenter.default.post(name: .test, object: Date())
                                }
                            }
                            .onReceive(NotificationCenter.default.publisher(for: .test)) { notification in
                                if let date = notification.object as? Date {
                                    timestamp = date
                                }
                            }
                    }
                }
            )
    }
}

extension Notification.Name {
    static let test = Notification.Name("test")
}

#Preview {
    EventSourceTest()
}
