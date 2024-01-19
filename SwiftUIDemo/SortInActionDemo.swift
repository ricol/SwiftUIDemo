//
//  ShapeDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/15.
//

import SwiftUI

struct SortInActionDemo: View {
    @StateObject var vm: ShapeDemoViewModel = ShapeDemoViewModel()
    @State var result: [Int] = []
    @State var output: String = ""
    
    func begin() async {
        output = "cancelling previous operation..."
        await SortMethod.theLock.requestCancel()
        var canstart = await SortMethod.theLock.canStart()
        while !canstart {
            output += "\nwait..."
            try! await Task.sleep(nanoseconds: 1000)
            canstart = await SortMethod.theLock.canStart()
        }
        output = "start..."
        await vm.data = SortMethod.buildData(num: SortMethod.MAX_NUM)
        let r = await SortMethod.verify(data: vm.data)
        output += "\(r ? "ordered" : "disordered")"
        output += "\nsorting..."
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        Button("Bubble") {
                            Task {
                                await begin()
                                let _ = await SortMethod.bubbleSort(data: vm.data) { d in
                                    vm.data = d
                                }
                                output += "end."
                                output += "\nverifing..."
                                let v = await SortMethod.verify(data: vm.data)
                                output += "\(v ? "pass" : "fail")"
                            }
                        }
                        Button("Selection") {
                            Task {
                                await begin()
                                let _ = await SortMethod.selectionSort(data: vm.data) { d in
                                    vm.data = d
                                }
                                output += "end."
                                output += "\nverifing..."
                                let v = await SortMethod.verify(data: vm.data)
                                output += "\(v ? "pass" : "fail")"
                            }
                        }
                        Button("Quick") {
                            Task {
                                await begin()
                                var d = vm.data
                                await SortMethod.quickSort(data: &d, left: 0, right: d.count - 1) { d in
                                    vm.data = d
                                }
                                output += "end."
                                output += "\nverifing..."
                                let v = await SortMethod.verify(data: vm.data)
                                output += "\(v ? "pass" : "fail")"
                            }
                        }
                        Button("Merge") {
                            Task {
                                await begin()
                                var d = vm.data
                                let final = await SortMethod.mergeSort(data: &d, left: 0, right: d.count - 1) { d in
                                    vm.data = d
                                }
//                                vm.data = final
                                output += "end."
                                output += "\nverifing..."
                                let v = await SortMethod.verify(data: vm.data)
                                output += "\(v ? "pass" : "fail")"
                            }
                        }
                        Spacer()
                    }.padding(SortMethod.MARGIN).buttonStyle(.borderedProminent)
                }
                Divider().padding(SortMethod.MARGIN)
                ScrollView(.vertical){
                    HStack {
                        Text(output).frame(alignment: .leading).padding()
                        Spacer()
                    }
                }
                Divider()
                Spacer()
                HStack {
                    ProcessView(vm: vm)
                    Spacer()
                }
            }
        }
    }
    
    typealias TFunc = ([TElement]) -> Void

    actor MyLock {
        private var _requestCancel = false
        private var _isInOperation = false
        
        func requestCancel() {
            if !_isInOperation { return }
            _requestCancel = true
        }
        
        func isInOperation() -> Bool {
            _isInOperation
        }
        
        func inOperation() {
            _isInOperation = true
        }
        
        func canStart() -> Bool {
            return !_requestCancel
        }
        
        func restore() {
            _requestCancel = false
            _isInOperation = false
        }
        
        func isRequestedCancel() -> Bool {
            return _requestCancel
        }
    }

    typealias TElement = SortMethod.Element

    struct SortMethod {
        static let theLock = MyLock()
        static let MAX_NUM = 100
        static let MARGIN: CGFloat = 10
        static let SLEEP: UInt64 = 100_000_000
        struct Element: Identifiable {
            let id = UUID()
            var value: Int
        }
        
        static func buildData(num: Int) async -> [TElement] {
            var data = [TElement]()
            let set = 0..<num
            (0..<num).forEach { _ in
                let e = TElement(value: set.randomElement()!)
                data.append(e)
            }
            return data
        }

        static func verify(data: [TElement]) async -> Bool {
            for i in 1..<data.count {
                if data[i - 1].value > data[i].value { return false }
            }
            return true
        }
        
        static func bubbleSort(data: [TElement], block: TFunc? = nil) async -> [TElement] {
            await theLock.inOperation()
            var result = data
            for i in (0..<result.count - 1) {
                for j in stride(from: result.count - 1, to: i, by: -1) {
                    if result[j - 1].value > result[j].value {
                        result.swapAt(j - 1, j)
                        if await theLock.isRequestedCancel() {
                            await theLock.restore()
                            return data
                        }
                        let r = result
                        DispatchQueue.main.async {
                            block?(r)
                        }
                        try! await Task.sleep(nanoseconds: SLEEP)
                    }
                }
            }
            block?(result)
            await theLock.restore()
            return result
        }

        static func selectionSort(data: [TElement], block: TFunc? = nil) async -> [TElement] {
            await theLock.inOperation()
            var result = data
            for i in 0..<(result.count - 1) {
                for j in (i + 1)..<result.count {
                    if result[j].value < result[i].value {
                        result.swapAt(i, j)
                        if await theLock.isRequestedCancel() {
                            await theLock.restore()
                            return data
                        }
                        let r = result
                        DispatchQueue.main.async {
                            block?(r)
                        }
                        try! await Task.sleep(nanoseconds: SLEEP)
                    }
                }
            }
            block?(result)
            await theLock.restore()
            return result
        }
        
        static func quickSort(data: inout [TElement], left: Int, right: Int, block: TFunc? = nil) async {
            await theLock.inOperation()
            if await theLock.isRequestedCancel() {
                await theLock.restore()
                return
            }
            if left >= right { return }
            let m = data[left]
            var leftSet = [TElement]()
            var rightSet = [TElement]()
            for i in (left + 1)...right {
                if data[i].value > m.value {
                    rightSet.append(data[i])
                }else if data[i].value <= m.value {
                    leftSet.append(data[i])
                }
            }
            if await theLock.isRequestedCancel() {
                await theLock.restore()
                return
            }
            data[left...right] = leftSet + [m] + rightSet
            let r = data
            DispatchQueue.main.async {
                block?(r)
            }
            try! await Task.sleep(nanoseconds: SLEEP)
            await quickSort(data: &data, left: left, right: left + leftSet.count - 1, block: block)
            await quickSort(data: &data, left: right - rightSet.count + 1, right: right, block: block)
            await theLock.restore()
        }
        
        static private func merge(left: [TElement], right: [TElement]) -> [TElement] {
            var result = [TElement]()
            var i = 0
            var j = 0
            while i < left.count && j < right.count {
                if left[i].value < right[j].value {
                    result.append(left[i])
                    i += 1
                }
                else {
                    result.append(right[j])
                    j += 1
                }
            }
            while i < left.count {
                result.append(left[i])
                i += 1
            }
            while j < right.count {
                result.append(right[j])
                j += 1
            }
            return result
        }
        
        static func mergeSort(data: inout [TElement], left: Int, right: Int, block: TFunc? = nil) async -> [TElement] {
            if left == right { return [data[left]] }
            if left > right { return [] }
            let m = Int(CGFloat(right + left) / 2.0)
            let a = await mergeSort(data: &data, left: left, right: m, block: block)
            let b = await mergeSort(data: &data, left: m + 1, right: right, block: block)
            data.replaceSubrange(left...right, with: merge(left: Array(data[left..<m]), right: Array(data[m...right])))
            let r = data
            DispatchQueue.main.async {
                block?(r)
            }
            try! await Task.sleep(nanoseconds: SLEEP)
            return merge(left: a, right: b)
        }
    }

    struct ProcessView: View {
        let WIDTH: CGFloat = UIScreen.main.bounds.width - SortMethod.MARGIN * 2
        let spacing: CGFloat = 2
        @ObservedObject var vm: ShapeDemoViewModel
        
        func buildShape(data: [TElement]) -> some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(data) { n in
                    Rectangle().frame(width: (CGFloat(n.value) / CGFloat(SortMethod.MAX_NUM)) * WIDTH, height: 2).background(Constants.colors.randomElement()!)
                }
            }.padding(SortMethod.MARGIN)
        }
        
        var body: some View {
            buildShape(data: vm.data)
        }
    }

    class ShapeDemoViewModel: ObservableObject {
        @Published var data: [TElement] = []
    }
}

#Preview {
    SortInActionDemo()
}
