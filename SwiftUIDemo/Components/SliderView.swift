//
//  SliderView.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/1/20.
//
import SwiftUI

struct SliderView: View {
    struct Segment: Hashable {
        let id = UUID()
        let title: String
    }
    class ViewModel: ObservableObject {
        let segments: [Segment]
        @Published var totalWidth: CGFloat = 0
        @Published var contentWidth: CGFloat = 0
        private var widthMapping = [Segment: CGFloat]()

        var spacing: CGFloat {
            var totalSegmentsWidth: CGFloat = 0.0
            segments.forEach { segment in
                if let width = widthMapping[segment] {
                    totalSegmentsWidth += width
                }
            }
            return (contentWidth - totalSegmentsWidth) / CGFloat(segments.count + 1)
        }

        func getPosition(index: Int) -> CGFloat {
            guard index >= 0, index < widthMapping.count else { return 0 }
            var total = 0.0
            for i in 0..<index {
                if let width = widthMapping[segments[i]] {
                    total += (width + CGFloat(spacing))
                }
            }
            return total + CGFloat(spacing)
        }
        
        func getWidth(index: Int) -> CGFloat {
            guard index >= 0, index < segments.count else { return 0 }
            return widthMapping[segments[index]] ?? 0
        }
        
        func updateWidth(value: CGFloat, position: Int) {
            widthMapping[segments[position]] = value
        }
        
        init(segments: [Segment]) {
            self.segments = segments
        }
    }
    
    @StateObject var vm: ViewModel
    @State private var index = -1
    let bgColor: Color
    let selectedColor: Color
    let titleColor: Color
    let font: Font
    let action: (Segment) -> Void
    private let bgHeight: CGFloat = 3
    private let sliderHeight: CGFloat = 3

    init(segments: [Segment], index: Int = 0, bgColor: Color = .gray, selectedColor: Color = .black, titleColor: Color = .black, font: Font = .title3, action: @escaping (Segment) -> Void) {
        self._vm = StateObject(wrappedValue: ViewModel(segments: segments))
        self.index = index
        self.bgColor = bgColor
        self.selectedColor = selectedColor
        self.titleColor = titleColor
        self.font = font
        self.action = action
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                VStack(alignment: .center) {
                    HStack(spacing: 0) {
                        Spacer()
                        ForEach(Array(vm.segments.enumerated()), id: \.offset) { index, segment in
                            IndividualSegmentView(widthIndex: $index, index: index, action: action, font: font, titleColor: titleColor, proxy: proxy, vm: vm)
                            if vm.segments.count == 2, index < 1 {
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    .onGeometryChange(for: CGSize.self, of: { proxy in
                        proxy.size
                    }, action: {
                        vm.contentWidth = $0.width
                    })
                    if vm.segments.count > 1 {
                        bgColor
                            .frame(minWidth: vm.totalWidth)
                            .frame(height: bgHeight).overlay {
                                if vm.segments.count > 2 {
                                    selectedColor.frame(width: vm.getWidth(index: index), height: sliderHeight)
                                        .position(x: vm.getWidth(index: index) / 2 + vm.getPosition(index: index) + max((vm.totalWidth - vm.contentWidth) / 2, 0), y: 2)
                                } else if vm.segments.count > 1 {
                                    selectedColor.frame(width: vm.totalWidth / 2.0, height: sliderHeight)
                                        .offset(x: vm.totalWidth / 2.0 * CGFloat(index) - vm.totalWidth / 4.0)
                                }
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.center)
        }.onGeometryChange(for: CGSize.self, of: { proxy in
            proxy.size
        }, action: {
            vm.totalWidth = $0.width
        })
    }
    
    private struct IndividualSegmentView: View {
        @Binding var widthIndex: Int
        let index: Int
        let action: (Segment) -> Void
        let font: Font
        let titleColor: Color
        let proxy: ScrollViewProxy
        @ObservedObject var vm: ViewModel
        var body: some View {
            Group {
                Button {
                    action(vm.segments[index])
                    withAnimation {
                        widthIndex = index
                        proxy.scrollTo(vm.segments[index].id, anchor: .center)
                    }
                } label: {
                    Text("\(vm.segments[index].title)").font(font).foregroundStyle(titleColor)
                }
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: {
                    vm.updateWidth(value: $0.width, position: index)
                }
            }.id(vm.segments[index].id)
        }
    }
}

struct SliderViewDemo: View {
    @State private var current: SliderView.Segment? = nil
    var body: some View {
        VStack(spacing: 32) {
            SliderView(segments: [SliderView.Segment(title: "AI")]) { segment in
                current = segment
            }
            SliderView(segments: [SliderView.Segment(title: "My booking classes"),
                                  SliderView.Segment(title: "Group classes")]) { segment in
                current = segment
            }
            SliderView(segments: [SliderView.Segment(title: "AI1"),
                                  SliderView.Segment(title: "AI2"),
                                 ]) { segment in
                current = segment
            }
            SliderView(segments: [
                SliderView.Segment(title: "AI1"),
                                  SliderView.Segment(title: "AI2"),
                                  SliderView.Segment(title: "AI3")
                                 ]) { segment in
                current = segment
            }
            SliderView(segments: [SliderView.Segment(title: "AI"),
                                  SliderView.Segment(title: "AI Conversation"),
                                  SliderView.Segment(title: "My booking classes")]) { segment in
                current = segment
            }
            SliderView(segments: [SliderView.Segment(title: "AI"),
                                  SliderView.Segment(title: "AI Conversation"),
                                  SliderView.Segment(title: "My privagte booking classes"),
                                  SliderView.Segment(title: "My scheduled classes"),
                                  SliderView.Segment(title: "Group cleasses"),
                                  SliderView.Segment(title: "Other")]) { segment in
                current = segment
            }
            Text("Selected: \(current?.title ?? "undefined")")
            Spacer()
        }
    }
}

#Preview {
    SliderViewDemo().padding()
}
