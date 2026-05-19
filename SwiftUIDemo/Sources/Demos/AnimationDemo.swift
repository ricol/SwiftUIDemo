//
//  AnimationDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/23.
//

import SwiftUI

struct AnimationDemo: View {
    @State var degree: Angle = Angle(degrees: 0)
    @State var size: CGSize = CGSize(width: 100, height: 100)
    @State var rotation: Angle = Angle(degrees: 0)
    @State var isOn: Bool = false
    var body: some View {
        Form {
            Section("Symbol effect") {
                HStack {
                    Text("Symbol effect: ")
                    Image(systemName: "wifi").symbolEffect(.variableColor.reversing)
                    Image(systemName: "bolt.slash.fill").symbolEffect(.pulse)
                    Image(systemName: "folder.fill.badge.person.crop").symbolEffect(.pulse)
                    // Add an effect in SwiftUI.
                    Image(systemName: "globe")
                        // Add effect with discrete behavior to image view.
                        .symbolEffect(.pulse, options: .repeat(3))
                    Image(systemName: "globe")
                        // Add effect with indefinite behavior to image view.
                        .symbolEffect(.pulse)
                }
            }
            Section("View Animation") {
                VStack {
                    Text("Hello, World!")
                        .foregroundStyle(Color.white)
                        .padding()
                        .frame(width: size.width, height: size.height)
                        .background(.blue)
                        .padding()
                        .background(.yellow)
                        .rotationEffect(degree)
                        .animation(.spring(.snappy, blendDuration: 2), value: degree)
                        .animation(.easeIn, value: size.width)
                        .animation(.easeIn, value: size.height)
                        .rotation3DEffect(rotation, axis: (x: 0.0, y: 1.0, z: 0.0))
                        .animation(.easeIn, value: rotation)
                    Divider()
                    HStack {
                        Button("Rotate") {
                            degree.degrees += 50
                        }
                        Button("Size") {
                            size.width += CGFloat((10...20).randomElement()!)
                            size.height += CGFloat((10...20).randomElement()!)
                        }
                        Button("3D") {
                            rotation.degrees += 10
                        }
                        Button("Reset") {
                            degree.degrees = 0
                            rotation.degrees = 0
                            size.width = 100
                            size.height = 100
                        }
                    }.buttonStyle(.borderedProminent)
                }
            }
            Section("Sprints Animation") {
                VStack {
                    Toggle(isOn: $isOn, label: {
                        Text("Toggle")
                    })
                }
            }
        }
    }
}

struct CustomProgressIndicator: View {
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20.0)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut(duration: 0.4), value: 2.0)
                }
                .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                Spacer()
                Button("run") {
                    withAnimation {
                        progress = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1].randomElement()!
                    }
                }
            }
        }
    }
}

#Preview {
    CustomProgressIndicator().frame(width: 100, height: 100)
}

struct AnimationDemoView: View {
    @State private var flag: Bool = false
    
    var body: some View {
        NavigationStack {
            Content(flag: flag).animation(.default, value: flag)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Button("Change") {
                            flag.toggle()
                        }
                    }
                }
        }
    }
    
    struct Content: View {
        let flag: Bool
        var body: some View {
            let layout = flag ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
            layout {
                A().border(flag ? .red : .blue).padding()
                B().background(flag ? .yellow : .green).padding()
            }
        }
    }
    
    struct A: View {
        var body: some View {
            Text("A").font(.title)
        }
    }
    
    struct B: View {
        var body: some View {
            Text("B").font(.title)
        }
    }
}

struct CardLayoutView: View {
    @State private var layoutStyle: LayoutStyle = .list
    
    enum LayoutStyle: CaseIterable {
        case list, grid, detailed
        
        var layout: AnyLayout {
            switch self {
            case .list:
                return AnyLayout(VStackLayout(spacing: 1))
            case .grid:
                return AnyLayout(HStackLayout(spacing: 1))
            case .detailed:
                return AnyLayout(VStackLayout(spacing: 8))
            }
        }
        
        var columns: [GridItem] {
            switch self {
            case .list:
                return [GridItem(.flexible())]
            case .grid:
                return [GridItem(.flexible()), GridItem(.flexible())]
            case .detailed:
                return [GridItem(.flexible())]
            }
        }
    }
    
    let items = [
        ("Apple", "Fruit", "🍎"),
        ("Carrot", "Vegetable", "🥕"),
        ("Bread", "Bakery", "🍞"),
        ("Milk", "Dairy", "🥛"),
        ("Chicken", "Meat", "🍗"),
        ("Eggs", "Dairy", "🥚")
    ]
    
    var body: some View {
        VStack {
            Picker("Layout", selection: $layoutStyle.animation(.spring())) {
                Text("List").tag(LayoutStyle.list)
                Text("Grid").tag(LayoutStyle.grid)
                Text("Detailed").tag(LayoutStyle.detailed)
            }
            .pickerStyle(.segmented)
            .padding()
            
            ScrollView {
                LazyVGrid(columns: layoutStyle.columns, spacing: 10) {
                    ForEach(items, id: \.0) { name, category, emoji in
                        layoutStyle.layout {
                            if layoutStyle != .grid {
                                Text(emoji)
                                    .font(.title)
                            }
                            
                            VStack(alignment: layoutStyle == .grid ? .center : .leading) {
                                Text(name)
                                    .fontWeight(.semibold)
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if layoutStyle == .detailed {
                                Divider()
                                Text("More details about \(name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                .padding()
            }
        }
    }
}

struct ConditionalLayoutView: View {
    @State private var isExpanded = false
    @State private var itemCount = 3
    
    var body: some View {
        VStack {
            Stepper("Items: \(itemCount)", value: $itemCount, in: 1...6)
                .padding()
            
            Toggle("Expanded Layout", isOn: $isExpanded.animation(.easeInOut))
                .padding()
            
            let layout = isExpanded ?
                AnyLayout(HStackLayout(spacing: 8)) :
                AnyLayout(VStackLayout(spacing: 4))
            
            layout {
                ForEach(1...itemCount, id: \.self) { index in
                    Capsule()
                        .fill(Color(hue: Double(index) / Double(itemCount), saturation: 0.8, brightness: 0.8))
                        .frame(height: 40)
                        .overlay(
                            Text("Item \(index)")
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        )
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

struct GridLayoutView: View {
    @State private var isGrid = false
    
    var body: some View {
        VStack {
            Toggle("Grid Layout", isOn: $isGrid.animation(.spring()))
                .padding()
            
            let layout = isGrid ?
                AnyLayout(VStackLayout()) :
                AnyLayout(HStackLayout())
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: isGrid ? 150 : 300))]) {
                ForEach(1...6, id: \.self) { index in
                    layout {
                        Image(systemName: "\(index).circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Item \(index)")
                                .fontWeight(.semibold)
                            Text("Description for item \(index)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
                }
            }
            .padding()
        }
    }
}

struct AdvancedLayoutView: View {
    @State private var layoutType: LayoutType = .horizontal
    
    enum LayoutType {
        case horizontal, vertical, zStack
        
        var layout: AnyLayout {
            switch self {
            case .horizontal:
                return AnyLayout(HStackLayout(spacing: 20))
            case .vertical:
                return AnyLayout(VStackLayout(spacing: 10))
            case .zStack:
                return AnyLayout(ZStackLayout())
            }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Layout", selection: $layoutType) {
                Text("Horizontal").tag(LayoutType.horizontal)
                Text("Vertical").tag(LayoutType.vertical)
                Text("ZStack").tag(LayoutType.zStack)
            }
            .pickerStyle(.segmented)
            .padding()
            
            layoutType.layout {
                ForEach(1...3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 15)
                        .fill([.blue, .green, .orange][index-1])
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("Item \(index)")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: layoutType)
            
            Spacer()
        }
    }
}

#Preview {
    AdvancedLayoutView()
}
