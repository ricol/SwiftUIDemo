//
//  SliderView.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/1/20.
//
import SwiftUI

struct SliderView: View {
    typealias Font = SwiftUI.Font
    struct Segment: Hashable {
        let id = UUID()
        let title: String
    }
    private class ViewModel: ObservableObject {
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

        func findIndexFor(selection: Segment) -> Int? {
            segments.firstIndex(where: { $0.title == selection.title })
        }

        init(segments: [Segment]) {
            self.segments = segments
        }
    }

    @StateObject private var vm: ViewModel
    @State private var currentIndex: Int = -1
    @Binding var selection: Segment?
    private let bgColor: Color
    private let fgColor: Color
    private let textColor: Color
    private let textFont: Font

    init(segments: [Segment], selection: Binding<Segment?>, bgColor: Color = .gray, fgColor: Color = .black, textColor: Color = .black, textFont: Font = .title3) {
        self._vm = StateObject(wrappedValue: ViewModel(segments: segments))
        self._selection = selection
        self.bgColor = bgColor
        self.fgColor = fgColor
        self.textColor = textColor
        self.textFont = textFont
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                VStack(alignment: .center) {
                    HStack(spacing: 0) {
                        Spacer()
                        ForEach(Array(vm.segments.enumerated()), id: \.offset) { index, _ in
                            IndividualSegmentView(index: index, selection: $selection, proxy: proxy, textColor: textColor, textFont: textFont, vm: vm)
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
                            .frame(height: 3).overlay {
                                if vm.segments.count > 2 {
                                    fgColor.frame(width: vm.getWidth(index: currentIndex), height: 3)
                                        .position(x: vm.getWidth(index: currentIndex) / 2 + vm.getPosition(index: currentIndex) + max((vm.totalWidth - vm.contentWidth) / 2, 0), y: 2)
                                } else if vm.segments.count > 1 {
                                    fgColor.frame(width: vm.totalWidth / 2.0, height: 3)
                                        .offset(x: vm.totalWidth / 2.0 * CGFloat(currentIndex) - vm.totalWidth / 4.0)
                                }
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.center)
            .onChange(of: selection) { _, _ in
                if let selection, let index = vm.findIndexFor(selection: selection) {
                    withAnimation {
                        currentIndex = index
                        proxy.scrollTo(vm.segments[index].id, anchor: .center)
                    }
                }
            }
        }.onGeometryChange(for: CGSize.self, of: { proxy in
            proxy.size
        }, action: {
            vm.totalWidth = $0.width
        })
    }

    private struct IndividualSegmentView: View {
        let index: Int
        @Binding var selection: Segment?
        let proxy: ScrollViewProxy
        let textColor: Color
        let textFont: Font
        @ObservedObject var vm: ViewModel
        var body: some View {
            Group {
                Button {
                    selection = vm.segments[index]
                } label: {
                    Text("\(vm.segments[index].title)").font(textFont).foregroundStyle(textColor)
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
    var body: some View {
        VStack(spacing: 32) {
            Demo(segments: [SliderView.Segment(title: "AI")])
            Demo(segments: [SliderView.Segment(title: "AI1"),
                            SliderView.Segment(title: "AI2")])
            Demo(segments: [SliderView.Segment(title: "AI1"),
                            SliderView.Segment(title: "AI2"),
                            SliderView.Segment(title: "AI3")])
            Demo(segments: [SliderView.Segment(title: "AI"),
                            SliderView.Segment(title: "My booking classes")])
            Demo(segments: [SliderView.Segment(title: "AI"),
                            SliderView.Segment(title: "AI Conversation"),
                            SliderView.Segment(title: "My privagte booking classes"),
                            SliderView.Segment(title: "My scheduled classes"),
                            SliderView.Segment(title: "Group cleasses"),
                            SliderView.Segment(title: "Other"),
                            SliderView.Segment(title: "AI3")])
        }
    }

    struct Demo: View {
        @State private var current: SliderView.Segment?
        let segments: [SliderView.Segment]
        var body: some View {
            VStack {
                SliderView(segments: segments, selection: $current)
                Text("Selected: \(current?.title ?? "undefined")")
            }.onAppear {
                current = SliderView.Segment(title: "AI3")
            }
        }
    }
}

#Preview {
    SliderViewDemo()
}
