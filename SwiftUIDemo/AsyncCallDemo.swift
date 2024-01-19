//
//  SortDemoView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/15.
//

import SwiftUI

struct AsyncCallDemo: View {
    @State var output: String = ""
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Button("bubble sort") {
                    Task {
                        output += "\(output == "" ? "" : "\n\n")bubble sort started..."
                        output += "\ngenerating data..."
                        let data = await buildData(num: MAX)
                        output += "\nverifing data..."
                        let ordered = await verify(data: data)
                        output += ordered ? "\nordered." : "\ndisordered."
                        output += "\nsorting..."
                        let result = await bubbleSort(data: data)
                        let verify = await verify(data: result)
                        output += verify ? "\nordered." : "\ndisordered."
                        output += "\nbubble sort done."
                    }
                }
                Button("selection sort") {
                    Task {
                        output += "\(output == "" ? "" : "\n\n")selection sort started..."
                        output += "\ngenerating data..."
                        let data = await buildData(num: MAX)
                        output += "\nverifing data..."
                        let ordered = await verify(data: data)
                        output += ordered ? "\nordered." : "\ndisordered."
                        output += "\nsorting..."
                        let result = await selectionSort(data: data)
                        let verify = await verify(data: result)
                        output += verify ? "\nordered." : "\ndisordered."
                        output += "\nselection sort done."
                    }
                }
                Button("quick sort") {
                    Task {
                        output += "\(output == "" ? "" : "\n\n")quick sort started..."
                        output += "\ngenerating data..."
                        let data = await buildData(num: MAX)
                        output += "\nverifing data..."
                        let ordered = await verify(data: data)
                        output += ordered ? "\nordered." : "\ndisordered."
                        output += "\nsorting..."
                        let result = await quickSort(data: data)
                        let verify = await verify(data: result)
                        output += verify ? "\nordered." : "\ndisordered."
                        output += "\nquick sort done."
                    }
                }
            }.buttonStyle(.borderedProminent)
            Divider()
            Text("Output:")
            ScrollView(.vertical) {
                Text(output)
            }
        }.padding().font(.body)
    }
    
    func bubbleSort(data: [Int]) async -> [Int] {
        var result = data
        for i in (0..<result.count - 1) {
            for j in stride(from: result.count - 1, to: i, by: -1) {
                if result[j - 1] > result[j] {
                    result.swapAt(j - 1, j)
                }
            }
        }
        return result
    }

    func selectionSort(data: [Int]) async -> [Int] {
        var result = data
        for i in 0..<(result.count - 1) {
            for j in (i + 1)..<result.count {
                if result[j] < result[i] { result.swapAt(i, j) }
            }
        }
        return result
    }

    func quickSort(data: [Int]) async -> [Int] {
        if data.count <= 1 { return data }
        var left = [Int]()
        var right = [Int]()
        for i in 1..<data.count {
            if data[i] > data[0] {
                right.append(data[i])
            }else if data[i] <= data[0] {
                left.append(data[i])
            }
        }
        
        return await quickSort(data: left) + [data[0]] + quickSort(data: right)
    }

    func buildData(num: Int) async -> [Int] {
        var data = [Int]()
        let set = 0..<num
        (0..<num).forEach { _ in
            data.append(set.randomElement()!)
        }
        return data
    }

    func verify(data: [Int]) async -> Bool {
        for i in 1..<data.count {
            if data[i - 1] > data[i] { return false }
        }
        return true
    }

    let MAX: Int = Int(1e4)
}

#Preview {
    AsyncCallDemo()
}
