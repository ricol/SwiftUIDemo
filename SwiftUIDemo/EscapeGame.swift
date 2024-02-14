//
//  EscapeGame.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/1/30.
//

import SwiftUI

let SLEEP = 200_000_000
let data = ["..........",
            ".>...x..x.",
            "...x....<.",
            ".....^....",
            ".....v.>..",
            "...>.x..x.",
            "...>..x...",
            ".>....xxx.",
            ".....^..x.",
            ".x.<....x.",
            "..x...<x..",
            "....x...^.",
            "....x.....",
            "....x.....",
            ".A..x.x.<x",
            "....x....."]

public func solution(_ B : inout [String], PosX: Binding<Int?>, PosY: Binding<Int?>, visited: Binding<[String: Bool]>, stack: Binding<[(Int, Int)]>) async -> Bool {
    // Implement your solution here
    let MAX_X: Int = B.count - 1
    let MAX_Y: Int = (B.first?.count ?? 1) - 1
    var guarded = [String: Bool]()
    func isPossible(x: Int, y: Int) -> Bool {
        if x <= MAX_X && x >= 0 && y <= MAX_Y && y >= 0 && board[x][y] == "." { return true }
        return false
    }
    
    var board = [[Character]]()
    var x: Int? = nil
    var y: Int? = nil
    for i in 0..<B.count {
        let rows = [Character](B[i])
        if x == nil && y == nil {
            for j in 0..<rows.count {
                if rows[j] == "A" {
                    x = i
                    y = j
                }
            }
        }
        board.append(rows)
    }
    
    for i in 0..<board.count {
        for j in 0..<board[i].count {
            if board[i][j] == ">" {
                guarded["\(i)_\(j)"] = true
                var k = j
                while k <= MAX_Y {
                    k += 1
                    if k > MAX_Y { break }
                    if board[i][k] == "." {
                        guarded["\(i)_\(k)"] = true
                    }else {
                        break
                    }
                }
            }else if board[i][j] == "<" {
                guarded["\(i)_\(j)"] = true
                var k = j
                while k >= 0 {
                    k -= 1
                    if k < 0 { break }
                    if board[i][k] == "." {
                        guarded["\(i)_\(k)"] = true
                    }else {
                        break
                    }
                }
            }else if board[i][j] == "^" {
                guarded["\(i)_\(j)"] = true
                var k = i
                while k >= 0 {
                    k -= 1
                    if k < 0 { break }
                    if board[k][j] == "." {
                        guarded["\(k)_\(j)"] = true
                    }else {
                        break
                    }
                }
            }else if board[i][j] == "v" {
                guarded["\(i)_\(j)"] = true
                var k = i
                while k <= MAX_X {
                    k += 1
                    if (k > MAX_X) { break }
                    if board[k][j] == "." {
                        guarded["\(k)_\(j)"] = true
                    }else {
                        break
                    }
                }
            }
        }
    }
    guard let x = x, let y = y else { return false }
    stack.wrappedValue.append((x, y))
    var currentX = x
    var currentY = y
    var canContinue = false
    while !stack.isEmpty {
        (currentX, currentY) = stack.wrappedValue.last!
        PosX.wrappedValue = currentX
        PosY.wrappedValue = currentY
        canContinue = true
        while canContinue {
            try! await Task.sleep(nanoseconds: UInt64(SLEEP))
            print("next...\(Date()), currentX: \(currentX), currentY: \(currentY)")
            if isPossible(x: currentX + 1, y: currentY) && visited.wrappedValue["\(currentX + 1)_\(currentY)"] == nil && guarded["\(currentX + 1)_\(currentY)"] == nil {
                stack.wrappedValue.append((currentX + 1, currentY))
                currentX += 1
                visited.wrappedValue["\(currentX)_\(currentY)"] = true
                canContinue = true
            }else if isPossible(x: currentX, y: currentY + 1) && visited.wrappedValue["\(currentX)_\(currentY + 1)"] == nil && guarded["\(currentX)_\(currentY + 1)"] == nil {
                stack.wrappedValue.append((currentX, currentY + 1))
                currentY += 1
                visited.wrappedValue["\(currentX)_\(currentY)"] = true
                canContinue = true
            }else if isPossible(x: currentX, y: currentY - 1) && visited.wrappedValue["\(currentX)_\(currentY - 1)"] == nil && guarded["\(currentX)_\(currentY - 1)"] == nil {
                stack.wrappedValue.append((currentX, currentY - 1))
                currentY -= 1
                visited.wrappedValue["\(currentX)_\(currentY)"] = true
                canContinue = true
            }else if isPossible(x: currentX - 1, y: currentY) && visited.wrappedValue["\(currentX - 1)_\(currentY)"] == nil && guarded["\(currentX - 1)_\(currentY)"] == nil  {
                stack.wrappedValue.append((currentX - 1, currentY))
                currentX -= 1
                visited.wrappedValue["\(currentX)_\(currentY)"] = true
                canContinue = true
            }else {
                canContinue = false
                stack.wrappedValue.popLast()
            }
            PosX.wrappedValue = currentX
            PosY.wrappedValue = currentY
            if currentX == MAX_X && currentY == MAX_Y { return true }
        }
    }
    return currentX == MAX_X && currentY == MAX_Y
}

struct Item: Identifiable, Hashable {
    let id = UUID()
    let value: String
    var x: Int
    var y: Int
}

extension String {
    func toElement() -> Item {
        return Item(value: self, x: 0, y: 0)
    }
}

extension Character {
    func toElement() -> Item {
        return String(self).toElement()
    }
}

struct EscapeGame: View {
    @State var x: Int?
    @State var y: Int?
    @State var state: String = "ready"
    @State var board: [[Item]] = [[Item]]()
    @State var visited = [String: Bool]()
    @State var stack = [(Int, Int)]()
    let space: CGFloat = 10
    
    func isInPath(x: Int, y: Int) -> Bool {
        for (i, j) in stack {
            if i == x && y == j { return true }
        }
        return false
    }
        
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    let w = (proxy.size.width - space * 9 - 2 * 10) / 10
                    VStack(spacing: 0) {
                        Divider()
                        ScrollView(.vertical) {
                            LazyVGrid(columns: [
                                GridItem(.fixed(w), spacing: space), GridItem(.fixed(w), spacing: space),
                                GridItem(.fixed(w), spacing: space), GridItem(.fixed(w), spacing: space),
                                GridItem(.fixed(w), spacing: space), GridItem(.fixed(w), spacing: space),
                                GridItem(.fixed(w), spacing: space), GridItem(.fixed(w), spacing: space),
                                GridItem(.fixed(w), spacing: space), GridItem(.fixed(w), spacing: space)], spacing: space, content: {
                                ForEach(board, id: \.self) { i in
                                    ForEach(i, id: \.self) { j in
                                        if isInPath(x: j.x, y: j.y) {
                                            Text(j.value).frame(width: w, height: w).background(.blue)
                                        }else {
                                            Text(j.value).frame(width: w, height: w).background((j.x == x && j.y == y ? .red : (visited["\(j.x)_\(j.y)"] == nil ? (j.x == board.count - 1 && j.y == board[0].count - 1 ? .green : .clear) : .yellow)))
                                        }
                                    }
                                }
                            })
                        }
                    }.padding(10)
                }
                Spacer()
                Divider()
                HStack {
                    if let x = x, let y = y {
                        Text("x: \(x), y: \(y)")
                    }
                    Spacer()
                    Text(state)
                }.padding()
            }.toolbar(content: {
                Button("Go") {
                    visited.removeAll()
                    stack.removeAll()
                    Task {
                        var b = [String]()
                        board.forEach { e in
                            var data = [Character]()
                            e.forEach { v in
                                data.append(Character(v.value))
                            }
                            b.append(String(data))
                        }
                        print(b)
                        state = "running..."
                        let result = await solution(&b, PosX: $x, PosY: $y, visited: $visited, stack: $stack)
                        print(result)
                        state = result ? "succeed" : "fail"
                    }
                }
            })
            .navigationTitle("List").navigationBarTitleDisplayMode(.inline).onAppear {
                var i = 0
                var j = 0
                var tmpB = [[Item]]()
                data.forEach { r in
                    var rows = [Item]()
                    j = 0
                    r.forEach { c in
                        let e = Item(value: String(c), x: i, y: j)
                        rows.append(e)
                        j += 1
                    }
                    tmpB.append(rows)
                    i += 1
                }
                board = tmpB
            }
        }
    }
}

#Preview {
    EscapeGame()
}
