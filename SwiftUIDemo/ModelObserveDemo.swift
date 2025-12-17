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
    }
    
    struct DemoView: View {
        @StateObject var vm: ViewModel = ViewModel()
        
        var body: some View {
            VStack {
                ForEach(vm.data) { m in
                    SubView(m: m)
                }
            }
        }
    }
    
    struct SubView: View {
        @ObservedObject var m: SubViewModel
        var body: some View {
            Button {
                m.flag.toggle()
            } label: {
                Text(m.title).background(m.flag ? .red : .clear)
            }
        }
    }
}

struct ModelObserveWrongWayDemo {
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
    }
    
    struct DemoView: View {
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
    ModelObserveWrongWayDemo.DemoView(vm: ModelObserveWrongWayDemo.ViewModel())
}

func test() {
    var s: String = ""
    let binding = Binding<String>(get: {s}, set: {s = $0})
}
