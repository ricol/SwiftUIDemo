//
//  GameDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/16.
//

import SwiftUI

class Element: Identifiable, ObservableObject, Equatable {
    var content: String
    var id = UUID()
    var isProcessing = false
    @Published var revealed: Bool
    @Published var empty: Bool
    
    init(content: String, id: UUID = UUID(), revealed: Bool = false, empty: Bool = false) {
        self.content = content
        self.id = id
        self.revealed = revealed
        self.empty = empty
    }
    
    static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.id == rhs.id
    }
}

class GameModel: ObservableObject {
    @Published var data = getData()
    var first: Element?
    var second: Element?
    @Published var gameOver: Bool = false
    var time: String = ""
    var started = Date()
    
    func hideAll() {
        data.forEach { e in
            e.revealed = false
        }
    }
    
    func isGameOver() -> Bool {
        return data.filter { e in
            !e.empty
        }.count <= 0
    }
    
    func reset() {
        data = getData()
        started = Date()
    }
    
    func selectElement(c: Element) {
        if c.isProcessing { return }
        c.isProcessing = true
        withAnimation {
            c.revealed.toggle()
        } completion: {
            c.isProcessing = false
            if self.first == nil {
                self.first = c
            }else if self.second == nil {
                self.second = c
                if let f = self.first, let s = self.second, f != s {
                    if f.content == s.content {
                        withAnimation {
                            f.empty = true
                            s.empty = true
                            self.hideAll()
                            self.first = nil
                            self.second = nil
                        } completion: {
                            if self.isGameOver() {
                                withAnimation {
                                    self.reset()
                                }
                            }
                        }
                    }else {
                        withAnimation {
                            self.hideAll()
                            self.first = nil
                            self.second = nil
                        }
                    }
                }else {
                    self.hideAll()
                    self.first = nil
                    self.second = nil
                }
            }else {
                self.hideAll()
                self.first = nil
                self.second = nil
            }
        }
    }
}

func getData() -> [Element] {
    var data = [Element]()
    for i in Constants.images {
        data.append(Element(content: i))
        data.append(Element(content: i))
    }
    return data.shuffled()
}

struct MemorizeGame: View {
    @StateObject var model: GameModel = GameModel()
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(model.data) { n in
                            TileView(model: model, c: n)
                        }
                    }
                    DisplayTimeView(model: model)
                }
            }.toolbar(content: {
                Button("RESET") {
                    withAnimation {
                        model.reset()
                    }
                }
                NavigationLink("SETTINGS") {
                    MemorizeSettingsView()
                }
            }).navigationTitle("Memorize").padding()
        }
    }
}

struct MemorizeSettingsView: View {
    var body: some View {
        Form {
            Section("Images") {
                
            }
        }
    }
}

struct TileView: View {
    @ObservedObject var model: GameModel
    @ObservedObject var c: Element
    let color = Constants.colors.randomElement()!
    let size: CGFloat = 50
    
    var body: some View {
        if c.empty {
            Rectangle().frame(width: size, height: size).foregroundColor(.white)
        } else {
            ZStack {
                if c.revealed {
                    Image(systemName: c.content).resizable().frame(width: size, height: size).padding().background(color)
                }else {
                    Text("").frame(width: size, height: size).padding().background(color)
                }
            }
            .onTapGesture {
                model.selectElement(c: c)
            }
        }
    }
}

#Preview {
    MemorizeGame()
}


struct DisplayTimeView: View {
    @ObservedObject var model: GameModel
    
    @State var time: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Time: " + time).font(.title).onReceive(timer, perform: { _ in
            time = String(format: "%.1f", Date().timeIntervalSince(model.started))
            model.time = time
        })
    }
}
