//
//  LayoutDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2025/10/29.
//

import SwiftUI

// Usage
struct MasonryExample: View {
    struct MasonryLayout: Layout {
        var columns: Int
        var spacing: CGFloat
        
        init(columns: Int = 2, spacing: CGFloat = 8) {
            self.columns = columns
            self.spacing = spacing
        }
        
        struct Cache {
            var columnHeights: [CGFloat]
            var sizes: [CGSize]
        }
        
        func makeCache(subviews: Subviews) -> Cache {
            Cache(columnHeights: Array(repeating: 0, count: columns), sizes: [])
        }
        
        func updateCache(_ cache: inout Cache, subviews: Subviews) {
            cache.sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        }
        
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
            // Reset column heights for calculation
            cache.columnHeights = Array(repeating: 0, count: columns)
            
            let availableWidth = proposal.width ?? 0
            let columnWidth = (availableWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            
            // Calculate positions and total height
            for size in cache.sizes {
                let aspectRatio = size.width / size.height
                let height = columnWidth / aspectRatio
                
                if let minHeightIndex = cache.columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset {
                    cache.columnHeights[minHeightIndex] += height + spacing
                }
            }
            
            let totalHeight = cache.columnHeights.max() ?? 0
            return CGSize(width: availableWidth, height: totalHeight)
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
            // Reset column heights for placement
            var columnHeights = Array(repeating: bounds.minY, count: columns)
            let availableWidth = bounds.width
            let columnWidth = (availableWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            
            for (index, subview) in subviews.enumerated() {
                let aspectRatio = cache.sizes[index].width / cache.sizes[index].height
                let height = columnWidth / aspectRatio
                
                // Find the column with minimum current height
                let (columnIndex, yPosition) = columnHeights.enumerated()
                    .min(by: { $0.element < $1.element })!
                    
                let xPosition = bounds.minX + CGFloat(columnIndex) * (columnWidth + spacing)
                
                subview.place(
                    at: CGPoint(x: xPosition, y: yPosition),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: columnWidth, height: height)
                )
                
                columnHeights[columnIndex] += height + spacing
            }
        }
    }
    
    let items = [200, 150, 250, 180, 220, 170, 190, 210]
    
    var body: some View {
        ScrollView {
            MasonryLayout(columns: 3, spacing: 8) {
                ForEach(items, id: \.self) { height in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hue: Double.random(in: 0...1), saturation: 0.7, brightness: 0.8))
                        .frame(height: CGFloat(height))
                        .overlay(
                            Text("\(Int(height))")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                }
            }
            .padding()
        }
    }
}

// Usage
struct CircularLayoutExample: View {
    struct CircularLayout: Layout {
        var radius: CGFloat
        var startAngle: Angle = .zero
        
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let diameter = radius * 2
            return CGSize(width: diameter, height: diameter)
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let angleStep = Angle.degrees(360 / Double(subviews.count))
            
            for (index, subview) in subviews.enumerated() {
                let angle = startAngle + angleStep * Double(index)
                let x = center.x + cos(angle.radians) * radius
                let y = center.y + sin(angle.radians) * radius
                
                subview.place(
                    at: CGPoint(x: x, y: y),
                    anchor: .center,
                    proposal: ProposedViewSize(width: 50, height: 50)
                )
            }
        }
    }
    
    @State private var radius: CGFloat = 100
    
    var body: some View {
        VStack {
            Slider(value: $radius, in: 50...200) {
                Text("Radius: \(Int(radius))")
            }
            .padding()
            
            CircularLayout(radius: radius) {
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(.purple)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("\(index + 1)")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                }
            }
            .frame(height: 400)
            .border(.gray)
        }
    }
}

// Usage
struct TagCloudExample: View {
    struct TagCloudLayout: Layout {
        var spacing: CGFloat = 8
        
        struct Cache {
            var sizes: [CGSize]
            var positions: [CGPoint]
        }
        
        func makeCache(subviews: Subviews) -> Cache {
            Cache(sizes: [], positions: [])
        }
        
        func updateCache(_ cache: inout Cache, subviews: Subviews) {
            cache.sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        }
        
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
            let (positions, totalSize) = calculatePositions(
                in: CGRect(origin: .zero, size: proposal.replacingUnspecifiedDimensions()),
                subviews: subviews,
                sizes: cache.sizes
            )
            cache.positions = positions
            return totalSize
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
            for (index, subview) in subviews.enumerated() {
                let position = cache.positions[index]
                subview.place(
                    at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(cache.sizes[index])
                )
            }
        }
        
        private func calculatePositions(in bounds: CGRect, subviews: Subviews, sizes: [CGSize]) -> ([CGPoint], CGSize) {
            var positions: [CGPoint] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for size in sizes {
                if currentX + size.width > bounds.width {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxWidth = max(maxWidth, currentX)
            }
            
            let totalHeight = currentY + lineHeight
            return (positions, CGSize(width: maxWidth, height: totalHeight))
        }
    }
    
    let tags = ["SwiftUI", "iOS", "Layout", "Custom", "Animation", "View", "Modifier", "Stack", "Grid", "Performance"]
    
    var body: some View {
        ScrollView {
            TagCloudLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
            }
            .padding()
        }
    }
}

struct IdealSizeDemo: View {
    var body: some View {
        VStack {
            Text("GeometryReader has been present since the birth of SwiftUI, playing a crucial role in many scenarios.")
                .fixedSize()
            Rectangle().fill(.orange)
                .fixedSize()
            Circle().fill(.red)
                .fixedSize()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0 ..< 50) { i in
                        Rectangle().fill(.blue).frame(width: 30, height: 30)
                            .overlay(Text("\(i)").foregroundStyle(.white))
                    }
                }
            }
            .fixedSize()
            VStack {
                Text("GeometryReader has been present since the birth of SwiftUI, playing a crucial role in many scenarios.")
                Rectangle().fill(.yellow)
            }
            .fixedSize()
        }.border(.red)
    }
}

struct IdealSizeDemo2: View {
    var body: some View {
        Text("GeometryReader has been present since the birth of SwiftUI, playing a crucial role in many scenarios.")
            .fixedSize(horizontal: false, vertical: true)
            .border(.red, width: 2)
            .frame(width: 100, height: 100)
            .border(.blue, width: 2)
    }
}

struct IdealSizeDemo3: View {
    var body: some View {
        HStack {
            // ViewThatFits result
            ViewThatFits(in: .vertical) {
                Text("1: GeometryReader has been present since the birth of SwiftUI, playing a crucial role in many scenarios.")
                Text("2: In addition, some views believe that:")
            }
            .border(.blue)
            .frame(width: 200, height: 100, alignment: .top)
            .border(.red)

            // Text1's ideal size ,only vetical fixed
            Text("1: GeometryReader has been present since the birth of SwiftUI, playing a crucial role in many scenarios.")
                .fixedSize(horizontal: false, vertical: true)
                .border(.blue)
                .frame(width: 200, height: 100, alignment: .top)
                .border(.red)

            // Text2's ideal size ,only vetical fixed
            Text("2: In addition, some views believe that:")
                .fixedSize(horizontal: false, vertical: true)
                .border(.blue)
                .frame(width: 200, height: 100, alignment: .top)
                .border(.red)
        }
    }
}

#Preview {
    IdealSizeDemo3()
}

struct SetIdealSize: View {
    @State var useIdealSize = false
    var body: some View {
        VStack {
            Button("Use Ideal Size") {
                useIdealSize.toggle()
            }
            .buttonStyle(.bordered)

            Rectangle()
                .fill(.orange)
                .frame(width: 100, height: 100)
                .fixedSize(horizontal: useIdealSize ? true : false, vertical: useIdealSize ? true : false)

            Rectangle()
                .fill(.cyan)
                .frame(idealWidth: 100, idealHeight: 100)
                .fixedSize(horizontal: useIdealSize ? true : false, vertical: useIdealSize ? true : false)

            Rectangle()
                .fill(.green)
                .fixedSize(horizontal: useIdealSize ? true : false, vertical: useIdealSize ? true : false)
        }
        .animation(.easeInOut, value: useIdealSize)
    }
}

#Preview {
    SetIdealSize()
}

struct InfiniteAutoScrollView: View {
    let items = ["Page 1", "Page 2", "Page 3", "Page 4"]
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<items.count, id: \.self) { index in
                VStack {
                    Text(items[index])
                        .font(.largeTitle)
                    Text("Swipe or wait for auto-scroll")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(15)
                .padding()
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 300)
        .onAppear {
            startCarouselTimer()
        }
        .onDisappear {
            stopCarouselTimer()
        }
    }
    
    private func startCarouselTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % items.count
            }
        }
    }
    
    private func stopCarouselTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    InfiniteAutoScrollView()
}
