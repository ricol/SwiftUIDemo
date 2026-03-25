//
//  NumberGameDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/20.
//

import SwiftUI

class NumberGameViewModel: ObservableObject {
    @Published var data = [Int]()
    @Published var isWin = false
    
    init() {
        start()
    }
    
    func start() {
        isWin = false
        data.removeAll()
        (1...9).forEach { i in
            data.append(i)
        }
        data = data.shuffled()
    }
    
    func getValue(i: Int, j: Int) -> Int? {
        if i < 0 || i > 2 || j < 0 || j > 2  { return nil }
        return data[i * 3 + j]
    }
    
    func setValue(i: Int, j: Int, value: Int) {
        if i < 0 || i > 2 || j < 0 || j > 2 { return }
        data[i * 3 + j] = value
    }
    
    func swap(i: Int, j: Int, m: Int, n: Int) {
        if i < 0 || i > 2 || j < 0 || j > 2 || m < 0 || m > 2 || n < 0 || n > 2 { return }
        if let d = getValue(i: i, j: j), let v = getValue(i: m, j: n) {
            setValue(i: i, j: j, value: v)
            setValue(i: m, j: n, value: d)
            isWin = check()
        }
    }
    
    func check() -> Bool {
        for i in 0..<9 {
            let x = i / 3
            let y = i % 3
            if getValue(i: x, j: y) != i + 1 { return false }
        }
        return true
    }
    
    func canSwap(i: Int, j: Int) -> (Bool, CGPoint?) {
        if i < 0 || i > 2 || j < 0 || j > 2 { return (false, nil) }
        if let top = getValue(i: i - 1, j: j), top == 9 { return (true, CGPoint(x: i - 1, y: j)) }
        if let bottom = getValue(i: i + 1, j: j), bottom == 9 { return (true, CGPoint(x: i + 1, y: j)) }
        if let left = getValue(i: i, j: j - 1), left == 9 { return (true, CGPoint(x: i, y: j - 1)) }
        if let right = getValue(i: i, j: j + 1), right == 9 { return (true, CGPoint(x: i, y: j + 1)) }
        return (false, nil)
    }
}

struct NumberGame: View {
    @StateObject var vm: NumberGameViewModel = NumberGameViewModel()
    var body: some View {
        VStack {
            Spacer()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(Array(vm.data.enumerated()), id: \.offset) { index, n in
                    Button {
                        if n == 9 { return }
                        let i = index / 3
                        let j = index % 3
                        let (canSwap, position) = vm.canSwap(i: i, j: j)
                        if canSwap, let position {
                            vm.swap(i: i, j: j, m: Int(position.x), n: Int(position.y))
                        }
                    } label: {
                        Text("\(n != 9 ? "\(n)" : "")").frame(width: 100, height: 100).background(n != 9 ? .blue : .clear).font(.title).foregroundColor(.white)
                    }
                }
            }.frame(width: 300, height: 300)
            Spacer()
            Divider()
            Button("Restart") {
                withAnimation {
                    vm.start()
                }
            }.font(.title).alert(isPresented: $vm.isWin, content: {
                Alert(title: Text("you win"))
            })
        }
    }
}

#Preview {
    NumberGame()
}
