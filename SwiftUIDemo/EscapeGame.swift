//
//  EscapeGame.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/1/30.
//

import SwiftUI

struct Item: Identifiable, Hashable {
    let id = UUID()
    let value: String
    var x: Int
    var y: Int
}

class EscapeGameViewModel: ObservableObject {
    @Published var PosX: Int?
    @Published var PosY: Int?
    @Published var state: String = "ready"
    var startX: Int?
    var startY: Int?
    var board: [[Item]] = [[Item]]()
    var visited = [String: Bool]()
    var stack = [(Int, Int)]()
    let space: CGFloat = 10
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
    
    init() {
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
    
    func isInPath(x: Int, y: Int) -> Bool {
        for (i, j) in stack {
            if i == x && y == j { return true }
        }
        return false
    }
    
    func getColor(x: Int, y: Int) -> Color {
        if x == board.count - 1 && y == board[0].count - 1 { return .green }
        if x == PosX && y == PosY { return .red }
        if isInPath(x: x, y: y) { return .blue }
        if let v = visited["\(x)_\(y)"], v { return .yellow }
        return .clear
    }

    func solve(recursive: Bool) {
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
            DispatchQueue.main.async {
                self.state = "running..."
            }
            let result = await solution(b, recursive: recursive)
            DispatchQueue.main.async {
                self.state = result ? "succeed" : "fail"
            }
        }
    }
    
    func solution(_ B : [String], recursive: Bool) async -> Bool {
        // Implement your solution here
        let MAX_X: Int = B.count - 1
        let MAX_Y: Int = (B.first?.count ?? 1) - 1
        var guarded = [String: Bool]()
        func isPossible(x: Int, y: Int) -> Bool {
            if x <= MAX_X && x >= 0 && y <= MAX_Y && y >= 0 && board[x][y] == "." { return true }
            return false
        }
        
        var board = [[Character]]()
        for i in 0..<B.count {
            let rows = [Character](B[i])
            if startX == nil && startY == nil {
                for j in 0..<rows.count {
                    if rows[j] == "A" {
                        startX = i
                        startY = j
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
        guard let startX, let startY else { return false }
        if recursive {
            var result = false
            func go(x: Int, y: Int) async {
                if visited["\(x)_\(y)"] == nil && guarded["\(x)_\(y)"] == nil {
                    try! await Task.sleep(nanoseconds: UInt64(SLEEP))
                    DispatchQueue.main.async {
                        self.PosX = x
                        self.PosY = y
                    }
                    if x == MAX_X && y == MAX_Y { result = true; return }
                    visited["\(x)_\(y)"] = true
                    if !result && isPossible(x: x - 1, y: y) { await go(x: x - 1, y: y) }
                    if !result && isPossible(x: x + 1, y: y)  { await go(x: x + 1, y: y) }
                    if !result && isPossible(x: x, y: y - 1)  { await go(x: x, y: y - 1) }
                    if !result && isPossible(x: x, y: y + 1)  { await go(x: x, y: y + 1) }
                }
            }
            await go(x: startX, y: startY)
            return result
        }else {
            stack.append((startX, startY))
            var currentX = startX
            var currentY = startY
            var canContinue = false
            while !stack.isEmpty {
                (currentX, currentY) = stack.last!
                let tmpX = currentX
                let tmpY = currentY
                DispatchQueue.main.async {
                    self.PosX = tmpX
                    self.PosY = tmpY
                }
                canContinue = true
                while canContinue {
                    try! await Task.sleep(nanoseconds: UInt64(SLEEP))
                    if isPossible(x: currentX + 1, y: currentY) && visited["\(currentX + 1)_\(currentY)"] == nil && guarded["\(currentX + 1)_\(currentY)"] == nil {
                        stack.append((currentX + 1, currentY))
                        currentX += 1
                        visited["\(currentX)_\(currentY)"] = true
                        canContinue = true
                    }else if isPossible(x: currentX, y: currentY + 1) && visited["\(currentX)_\(currentY + 1)"] == nil && guarded["\(currentX)_\(currentY + 1)"] == nil {
                        stack.append((currentX, currentY + 1))
                        currentY += 1
                        visited["\(currentX)_\(currentY)"] = true
                        canContinue = true
                    }else if isPossible(x: currentX, y: currentY - 1) && visited["\(currentX)_\(currentY - 1)"] == nil && guarded["\(currentX)_\(currentY - 1)"] == nil {
                        stack.append((currentX, currentY - 1))
                        currentY -= 1
                        visited["\(currentX)_\(currentY)"] = true
                        canContinue = true
                    }else if isPossible(x: currentX - 1, y: currentY) && visited["\(currentX - 1)_\(currentY)"] == nil && guarded["\(currentX - 1)_\(currentY)"] == nil  {
                        stack.append((currentX - 1, currentY))
                        currentX -= 1
                        visited["\(currentX)_\(currentY)"] = true
                        canContinue = true
                    }else {
                        canContinue = false
                        let _ = stack.popLast()
                    }
                    let tmpX = currentX
                    let tmpY = currentY
                    DispatchQueue.main.async {
                        self.PosX = tmpX
                        self.PosY = tmpY
                    }
                    if currentX == MAX_X && currentY == MAX_Y { return true }
                }
            }
            return currentX == MAX_X && currentY == MAX_Y
        }
    }
}

struct EscapeGame: View {
    @StateObject var vm: EscapeGameViewModel = EscapeGameViewModel()
        
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    let w = (proxy.size.width - vm.space * 9 - 2 * 10) / 10
                    VStack(spacing: 0) {
                        Divider()
                        ScrollView(.vertical) {
                            LazyVGrid(columns: [
                                GridItem(.fixed(w), spacing: vm.space), GridItem(.fixed(w), spacing: vm.space),
                                GridItem(.fixed(w), spacing: vm.space), GridItem(.fixed(w), spacing: vm.space),
                                GridItem(.fixed(w), spacing: vm.space), GridItem(.fixed(w), spacing: vm.space),
                                GridItem(.fixed(w), spacing: vm.space), GridItem(.fixed(w), spacing: vm.space),
                                GridItem(.fixed(w), spacing: vm.space), GridItem(.fixed(w), spacing: vm.space)], spacing: vm.space, content: {
                                    ForEach(vm.board, id: \.self) { i in
                                        ForEach(i, id: \.self) { j in
                                            Text(j.value).frame(width: w, height: w).background(vm.getColor(x: j.x, y: j.y))
                                        }
                                    }
                            })
                        }
                    }.padding(10)
                }
                Spacer()
                Divider()
                HStack {
                    if let x = vm.PosX, let y = vm.PosY {
                        Text("x: \(x), y: \(y)")
                    }
                    Spacer()
                    Text(vm.state)
                }.padding()
            }.toolbar(content: {
                Button("BackTrack") {
                    vm.solve(recursive: false)
                }
                Button("Recursive") {
                    vm.solve(recursive: true)
                }
            })
            .navigationTitle("Escape Game").navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EscapeGame()
}
