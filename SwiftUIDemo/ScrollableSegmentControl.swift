//
//  ScrollableSegmentsControl.swift
//  EfektaMobile
//
//  Created by ricolwang on 2025/1/27.
//  Copyright © 2025 EF. All rights reserved.
//

import SwiftUI

class SegmentModel: Identifiable, ObservableObject {
    typealias TAction = () -> Void
    
    let id = UUID()
    var value: String
    var action: TAction?
    var font: Font
    var bgHighlightGradientColors: [Color]
    var borderColor: Color
    var borderHightLightColor: Color
    var borderWidth: CGFloat
    var bgColor: Color
    var bgHighlightColor: Color
    var fgColor: Color
    var fgHighLightColor: Color
    var cornerRadius: CGFloat
    @Published var selected: Bool
    
    var borderDisplayColor: Color {
        get {
            selected ? borderHightLightColor : borderColor
        }
    }
    
    var bgDisplayColor: Color {
        get {
            selected ? bgHighlightColor : bgColor
        }
    }
    
    var fgDislayColor: Color {
        get {
            selected ? fgHighLightColor : fgColor
        }
    }
    
    init(value: String,
         selected: Bool = false,
         font: Font = .body,
         bgHighlightGradientColors: [Color] = [],
         borderColor: Color = .black,
         borderHightLightColor: Color = .black,
         borderWidth: CGFloat = 2,
         bgColor: Color = .white,
         bgHighlightColor: Color = .black,
         fgColor: Color = .black,
         fgHighLightColor: Color = .white,
         cornerRadius: CGFloat = 8,
         action: TAction? = nil) {
        self.value = value
        self.action = action
        self.selected = selected
        self.font = font
        self.bgHighlightGradientColors = bgHighlightGradientColors
        self.borderColor = borderColor
        self.borderHightLightColor = borderHightLightColor
        self.borderWidth = borderWidth
        self.bgColor = bgColor
        self.bgHighlightColor = bgHighlightColor
        self.fgColor = fgColor
        self.fgHighLightColor = fgHighLightColor
        self.cornerRadius = cornerRadius
    }
    
    func toggle() {
        selected.toggle()
    }
    
    func reset() {
        selected = false
    }
    
    func select() {
        selected = true
    }
}

class ViewModel: ObservableObject {
    @Published var data: [SegmentModel]
    var width: CGFloat?
    var height: CGFloat
    var space: CGFloat
    var paddingVertical: CGFloat
    var paddingHorizonal: CGFloat

    init(data: [SegmentModel] = [],
         width: CGFloat? = nil,
         height: CGFloat = 32,
         space: CGFloat = 10,
         paddingVertical: CGFloat = 0,
         paddingHorizonal: CGFloat = 12) {
        self.data = data
        self.width = width
        self.height = height
        self.space = space
        self.paddingVertical = paddingVertical
        self.paddingHorizonal = paddingHorizonal
    }
    
    func select(m: SegmentModel?) {
        data.forEach { $0.reset() }
        if let m = m, let index = data.firstIndex(where: { $0.id == m.id }) {
            data[index].select()
        }
    }
}

struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct ScrollableSegmentsControl: View {
    @StateObject var vm: ViewModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            HStack(alignment: .center) {
                ScrollableSegmentMainView(vm: vm)
                    .scrollIndicators(.never)
            }
        } else {
            ScrollableSegmentMainView(vm: vm)
        }
    }
}

struct ScrollableSegmentMainView: View {
    @ObservedObject var vm: ViewModel
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollSegementView(vm: vm).scrollClipDisabled()
        } else {
            ScrollSegementView(vm: vm)
        }
    }
}

struct ScrollSegementView: View {
    let vm: ViewModel
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: vm.space) {
                    ForEach(vm.data) { model in
                        SegmentView(model: model, vm: vm, proxy: proxy)
                            .id(model.id)
                    }
                }
            }
        }
    }
}

struct SegmentView: View {
    @ObservedObject var model: SegmentModel
    let vm: ViewModel
    let proxy: ScrollViewProxy
    
    var body: some View {
        ZStack {
            if model.selected, model.bgHighlightGradientColors.count > 0 {
                LinearGradient(colors: model.bgHighlightGradientColors,
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .frame(width: vm.width, height: vm.height)
                    .cornerRadius(model.cornerRadius)
            }
            Button {
                if !model.selected {
                    vm.select(m: model)
                    model.action?()
                }
                withAnimation {
                    proxy.scrollTo(model.id, anchor: .center)
                }
            } label: {
                Text(model.value)
                    .font(model.font)
                    .padding(.horizontal, vm.paddingHorizonal)
                    .padding(.vertical, vm.paddingVertical)
                    .frame(width: vm.width, height: vm.height)
                    .background(model.bgDisplayColor)
                    .foregroundStyle(model.fgDislayColor)
                    .overlay(RoundedRectangle(cornerRadius: model.cornerRadius)
                            .stroke(model.borderDisplayColor, lineWidth: model.borderWidth))
                    .cornerRadius(model.cornerRadius)
            }
            .buttonStyle(NoHighlightButtonStyle())
        }
    }
}

class ScrollableSegmentsHostingController: UIHostingController<ScrollableSegmentsControl> {
    private let vm = ViewModel(data: [])
    init(segments: [SegmentModel] = [],
         height: CGFloat = 32,
         paddingVertical: CGFloat = 0,
         paddingHorizonal: CGFloat = 12) {
        vm.data = segments
        vm.height = height
        vm.paddingVertical = paddingVertical
        vm.paddingHorizonal = paddingHorizonal
        super.init(rootView: ScrollableSegmentsControl(vm: self.vm))
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selectedSegmentIndex: Int {
        get {
            vm.data.firstIndex { $0.selected } ?? -1
        }
        set {
            if newValue >= -1 && newValue < vm.data.count {
                vm.select(m: newValue >= 0 ? vm.data[newValue] : nil)
            }
        }
    }
    
    func addSegment(s: SegmentModel) {
        vm.data.append(s)
    }
}

#Preview {
    let data = [
        SegmentModel(value: "AI Conversations",
                     bgHighlightGradientColors: [.red, .blue],
                     borderHightLightColor: .clear,
                     bgColor: .clear,
                     bgHighlightColor: .clear),
        SegmentModel(value: "Private class"),
        SegmentModel(value: "Public class"),
        SegmentModel(value: "Others")
    ]
    ScrollableSegmentsControl(vm: ViewModel(data: data))
}

struct MyViewModel: Identifiable {
    let id = UUID()
    let title: String
}

struct ExtractedView: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "pencil")
            Text(title)
        }
    }
}

struct DemoView: View {
    let models = [MyViewModel(title: Constants.cities.randomElement()!),
                  MyViewModel(title: Constants.cities.randomElement()!),
                  MyViewModel(title: Constants.cities.randomElement()!),
    ]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(models) { m in
                        ExtractedView(title: m.title) {
                            withAnimation {
                                proxy.scrollTo(m.id, anchor: .center)
                            }
                        }
                    }
                }
                .padding()
                .border(Color.blue, width: 4)
            }
            .border(Color.red, width: 2)
        }
    }
}

#Preview {
    DemoView()
}
