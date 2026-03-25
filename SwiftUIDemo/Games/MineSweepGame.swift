//
//  MineGame.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/24.
//

import SwiftUI

class Mine: NSObject, Identifiable, ObservableObject {
    var id = UUID()
    var x: Int = 0
    var y: Int = 0
    var isMine: Bool = (0...100).randomElement()! < 10
    @Published var flagged: Bool = false
    @Published var sweeped: Bool = false
    @Published var revealed: Bool = false
    @Published var highlighted: Bool = false
    @Published var count: Int? = nil
    var processed: Bool {
        if flagged { return true }
        if sweeped { return true }
        return false
    }
    
    init(id: UUID = UUID(), x: Int, y: Int, isMine: Bool, flagged: Bool, sweeped: Bool, revealed: Bool, highlighted: Bool, count: Int? = nil) {
        self.id = id
        self.x = x
        self.y = y
        self.isMine = isMine
        self.flagged = flagged
        self.sweeped = sweeped
        self.revealed = revealed
        self.highlighted = highlighted
        self.count = count
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    func getFlaggedCopy(value: Bool) -> Mine {
//        Mine(id: id, x: x, y: y, isMine: isMine, flagged: value, sweeped: sweeped, revealed: revealed, highlighted: highlighted, count: count)
        flagged = value
        return self
    }
    
    func getSweeppedCopy(value: Bool) -> Mine {
//        Mine(id: id, x: x, y: y, isMine: isMine, flagged: flagged, sweeped: value, revealed: revealed, highlighted: highlighted, count: count)
        sweeped = value
        return self
    }
    
    func getRevealedCopy(value: Bool) -> Mine {
//        Mine(id: id, x: x, y: y, isMine: isMine, flagged: flagged, sweeped: sweeped, revealed: value, highlighted: highlighted, count: count)
        revealed = value
        return self
    }
    
    func getCountUpdatedCopy(count: Int?) -> Mine {
//        Mine(id: id, x: x, y: y, isMine: isMine, flagged: flagged, sweeped: sweeped, revealed: revealed, highlighted: highlighted, count: count)
        self.count = count
        return self
    }
    
    func getHighlightedCopy(value: Bool) -> Mine {
//        Mine(id: id, x: x, y: y, isMine: isMine, flagged: flagged, sweeped: sweeped, revealed: revealed, highlighted: value, count: count)
        highlighted = value
        return self
    }
}

class MineGameModel: ObservableObject {
    private var allowUpdate = true
    var mines: [[Mine]] = [[Mine]]() {
        willSet {
            if allowUpdate { objectWillChange.send() }
        }
    }
    @Published var youloose: Bool = false {
        didSet {
            if youloose {
                //reveal all mines
                mines.forEach { mm in
                    mm.forEach { m in
                        if m.isMine {
                            mines[m.x][m.y] = m.getRevealedCopy(value: true)
                        }
                    }
                }
                gameOver = true
            }
        }
    }
    @Published var youwin: Bool = false
    var inProcessing: Bool = false
    var gameOver: Bool = true
    var totalX: Int
    var totalY: Int
    var totalMine: Int {
        var total = 0
        mines.forEach { mm in
            mm.forEach { m in
                if m.isMine { total += 1 }
            }
        }
        return total
    }
    var totalSweeped: Int {
        var total = 0
        mines.forEach { mm in
            mm.forEach { m in
                if m.sweeped { total += 1 }
            }
        }
        return total
    }
    var totalFlagged: Int {
        var total = 0
        mines.forEach { mm in
            mm.forEach { m in
                if m.flagged { total += 1 }
            }
        }
        return total
    }
    @Published var totalMineLeft: Int = 0
    
    init(x: Int, y: Int) {
        totalX = x
        totalY = y
        (0..<totalX).forEach { i in
            var m = [Mine]()
            (0..<totalY).forEach { j in
                m.append(Mine(x: i, y: j))
            }
            mines.append(m)
        }
    }
    
    func restart() {
        mines = [[Mine]]()
        (0..<totalX).forEach { i in
            var m = [Mine]()
            (0..<totalY).forEach { j in
                m.append(Mine(x: i, y: j))
            }
            mines.append(m)
        }
        gameOver = false
        totalMineLeft = totalMine - totalFlagged
    }
    
    func getValue(i: Int, j: Int) -> Mine? {
        if i < 0 || i >= totalX { return nil }
        if j < 0 || j >= totalY { return nil }
        return mines[i][j]
    }
    
    func getSurroundingMines(i: Int, j: Int) -> Int {
        let surrounding = getSurrounding(i: i, j: j)
        var total = 0
        surrounding.forEach { p in
            if let m = getValue(i: Int(p.x), j: Int(p.y)), m.isMine { total += 1}
        }
        return total
    }
    
    func getSurrounding(i: Int, j: Int) -> [CGPoint] {
        [CGPoint(x: i - 1, y: j - 1),   CGPoint(x: i - 1, y: j),    CGPoint(x: i - 1, y: j + 1),
         CGPoint(x: i, y: j - 1),                                   CGPoint(x: i, y: j + 1),
         CGPoint(x: i + 1, y: j - 1),   CGPoint(x: i + 1, y: j),    CGPoint(x: i + 1, y: j + 1)]
    }
    
    var checked = Set<Mine>()
//    let delay: CGFloat = 0
    func revealSurroundingArea(i: Int, j: Int, begin: Bool = true) {
//        if let m = getValue(i: i, j: j) {
//            DispatchQueue.main.sync {
//                self.mines[i][j] = m.getHighlightedCopy(value: false)
//            }
//        }
        if begin { checked.removeAll() }
        let surrounding = getSurrounding(i: i, j: j)
        surrounding.forEach { p in
            if let m = getValue(i: Int(p.x), j: Int(p.y)), !checked.contains(m), !m.flagged {
//                Thread.sleep(forTimeInterval: delay)
                checked.insert(m)
//                DispatchQueue.main.sync {
//                    self.mines[m.x][m.y] = m.getHighlightedCopy(value: true)
//                }
//                Thread.sleep(forTimeInterval: delay)
                if !m.isMine {
                    let c = getSurroundingMines(i: m.x, j: m.y)
                    DispatchQueue.main.sync {
                        self.mines[m.x][m.y] = m.getCountUpdatedCopy(count: c).getSweeppedCopy(value: true)
                    }
                    if c == 0 {
                        revealSurroundingArea(i: Int(p.x), j: Int(p.y), begin: false)
                    }
                }
            }
        }
    }
    
    func checkWin() -> Bool {
        for mm in mines {
            for m in mm {
                if m.isMine && !m.flagged { return false }
                if !m.processed { return false }
            }
        }
        return true
    }
    
    func sweep(i: Int, j: Int) {
        guard !inProcessing, let m = getValue(i: i, j: j) else { return }
        if m.flagged { return }
        if m.isMine { youloose = true; gameOver = true } else
        {
            let count = getSurroundingMines(i: m.x, j: m.y)
            mines[m.x][m.y] = m.getCountUpdatedCopy(count: count).getSweeppedCopy(value: true)
            //check surrounding aear
            if count == 0 {
                inProcessing = true
                allowUpdate = false
                DispatchQueue.global().async {
                    self.revealSurroundingArea(i: m.x, j: m.y)
                    self.autoFlagMine()
                    self.allowUpdate = true
                    DispatchQueue.main.async {
                        self.inProcessing = false
                    }
                }
            }else {
                if checkWin() { youwin = true; gameOver = true }
            }
        }
    }
    
    func autoFlagMine() {
        self.mines.forEach { mm in
            mm.forEach { m in
                autoCheck(i: m.x, j: m.y, value: m.count)
            }
        }
        
        func autoCheck(i: Int, j: Int, value: Int?) {
            guard let value = value else { return }
            if value == 0 { return }
            let surrounding = getSurrounding(i: i, j: j)
            var remainingUnSweeped = 0
            var data = [Mine]()
            surrounding.forEach { p in
                if let m = getValue(i: Int(p.x), j: Int(p.y)) {
                    if !m.sweeped { data.append(m); remainingUnSweeped += 1}
                }
            }
            if remainingUnSweeped == value {
                DispatchQueue.main.sync {
                    data.forEach { m in
                        mines[m.x][m.y] = m.getFlaggedCopy(value: true)
                    }
                    totalMineLeft = totalMine - totalFlagged
                    if checkWin() { youwin = true; gameOver = true }
                }
            }
        }
    }
    
    func flag(i: Int, j: Int) {
        guard !inProcessing, let m = getValue(i: i, j: j) else { return }
        mines[m.x][m.y] = m.getFlaggedCopy(value: !m.flagged)
        totalMineLeft = totalMine - totalFlagged
        if checkWin() { youwin = true; gameOver = true }
    }
}

enum Operation {
    case sweep, flag, none
}

struct MineSweepGame: View {
    @State var totalMine: Int = 0
    @State var op: Operation = .sweep
    @StateObject var vm: MineGameModel = MineGameModel(x: 15, y: 8)
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.green, .yellow], startPoint: .top, endPoint: .bottom)
            VStack {
                Spacer()
                ControlView(vm: vm, op: $op)
                Divider()
                ScrollView(.vertical) {
                    BodyView(vm: vm, op: $op)
                }.frame(height: 650)
                Spacer()
                HStack {
                    Text("Total mine: \(vm.totalMineLeft)").foregroundStyle(.blue).font(.title2)
                }
            }.padding()
        }.ignoresSafeArea()
    }
}

#Preview {
    MineSweepGame()
}

fileprivate struct ControlView: View {
    @ObservedObject var vm: MineGameModel
    @Binding var op: Operation
    var body: some View {
        HStack {
            Button("Start") {
                vm.restart()
            }.buttonStyle(.borderedProminent)
            Spacer()
            HStack {
                if op == .flag {
                    Button("Flag") {
                        op = .flag
                    }.buttonStyle(.borderedProminent)
                }else {
                    Button("Flag") {
                        op = .flag
                    }.buttonStyle(.bordered)
                }
                if op == .sweep {
                    Button("Sweep") {
                        op = .sweep
                    }.buttonStyle(.borderedProminent)
                }else {
                    Button("Sweep") {
                        op = .sweep
                    }.buttonStyle(.bordered)
                }
            }.opacity(vm.gameOver ? 0 : 1)
        }.foregroundStyle(.white).font(.title2).buttonStyle(.bordered)
    }
}

fileprivate struct BodyView: View {
    @ObservedObject var vm: MineGameModel
    @Binding var op: Operation
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                           ], content: {
            ForEach(vm.mines, id: \.self) { mines in
                ForEach(mines) { m in
                    MineView(vm: vm, m: m, op: $op)
                }
            }
            .alert(isPresented: $vm.youwin) {
                Alert(title: Text("You win! :)"))
            }
        }).alert(isPresented: $vm.youloose) {
            Alert(title: Text("You loose! :("))
        }
    }
}

struct MineView: View {
    let size: CGFloat = 35
    @ObservedObject var vm: MineGameModel
    @State var m: Mine
    @Binding var op: Operation
    var body: some View {
        Button {
            switch op {
            case .sweep:
                vm.sweep(i: m.x, j: m.y)
            case .flag:
                vm.flag(i: m.x, j: m.y)
            case .none:
                break
            }
        } label: {
            Rectangle().frame(width: size, height: size).foregroundColor(m.sweeped ? .clear : .white).overlay {
                ZStack {
                    if m.flagged { Image(systemName: "flag.fill").resizable().frame(width: 10, height: 10).foregroundStyle(.red) }
                    if m.revealed && m.isMine { Image("bomb").resizable().frame(width: 20, height: 20) }
                    if let count = m.count {
                        if count > 0 { Text("\(count)") }
                    }
                    if m.highlighted {
                        Rectangle().foregroundStyle(.red)
                    }
                }
            }
        }
    }
}
