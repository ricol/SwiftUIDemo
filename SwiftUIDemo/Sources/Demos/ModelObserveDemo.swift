//
//  DemoView.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2025/2/10.
//

import SwiftUI

struct ModelObserveDemo {
    class SubViewModel: ObservableObject, Identifiable {
        let id = UUID()
        @Published var flag: Bool = false
        let title: String = "hello"
    }
    
    class ViewModel: ObservableObject {
        @Published var data: [SubViewModel] = [SubViewModel(),
                                               SubViewModel(),
                                               SubViewModel(),
                                               SubViewModel()
        ]
        var value: Bool = false
        @Published var publishedValue: Bool = false
    }
    
    struct DemoView: View {
        @StateObject var vm: ViewModel = ViewModel()
        
        var body: some View {
            let _ = print("DemoView created...")
            VStack {
                ForEach(vm.data) { m in
                    SubView(m: m)
                }
                Divider()
                ChildView(vm: vm)
                Button("Change Value") {
                    vm.value.toggle()
                }
                Button("Change Published Value") {
                    vm.publishedValue.toggle()
                }
                Text("vm.value: \(vm.value ? "true" : "false")")
                Text("vm.publishedValue: \(vm.publishedValue ? "true" : "false")")
            }
        }
    }

    struct ChildView: View {
        @ObservedObject var vm: ViewModel
        var body: some View {
            let _ = print("ChildView created...")
            Text("ChildView holding the vm but do not use its data")
        }
    }

    struct SubView: View {
        @ObservedObject var m: SubViewModel
        var body: some View {
            let _ = print("SubView created...")
            Button {
                m.flag.toggle()
            } label: {
                Text(m.title).background(m.flag ? .red : .clear)
            }
        }
    }

    //@Published var flag won't publish changes to the view as it is not directly in the ViewModel

    struct DemoViewWrongWay: View {
        @StateObject var vm: ViewModel = ViewModel()

        var body: some View {
            VStack {
                ForEach(vm.data) { m in
                    Button {
                        m.flag.toggle()
                    } label: {
                        Text(m.title).background(m.flag ? .red : .clear)
                    }
                }
            }
        }
    }
}

#Preview {
    ModelObserveDemo.DemoView(vm: ModelObserveDemo.ViewModel())
}

#Preview {
    ModelObserveDemo.DemoViewWrongWay(vm: ModelObserveDemo.ViewModel())
}
