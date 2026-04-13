import SwiftUI

struct LayoutProtocolExample: View {
    let views = (0..<8).map { _ in CGFloat.random(in: 100...150) }
    @State var index = 0
    var body: some View {
        VStack {
            Picker("", selection: $index) {
                ForEach(views.indices, id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
            .pickerStyle(.segmented)
            .zIndex(2)
            LayoutDemoView.AlignmentBottomLayout {
                ForEach(views.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.orange.gradient)
                        .overlay(Text("\(i)").font(.title))
                        .padding([.horizontal, .top], 10)
                        .frame(height: views[i])
                        .alignmentActive(index == i ? true : false)
                }
            }
            .animation(.default, value: index)
            .frame(width: 300, height: 400)
            .clipped()
            .border(.blue)
        }
        .padding(20)
    }
}

struct LayoutProtocolDemo: View {
    @State var show = false
    var body: some View {
        Color.clear
            .overlay(
                LayoutDemoView.AlignmentBottomLayout {
                    RedView()
                        .alignmentActive(show ? false : true)
                    GreenView()
                        .alignmentActive(show ? true : false)
                }
                .animation(.default, value: show)
            )
            .ignoresSafeArea()
            .overlayButton(show: $show)
    }
}

#Preview {
    LayoutProtocolDemo()
}

#Preview {
    LayoutProtocolExample()
}

extension View {
    func alignmentActive(_ isActive: Bool) -> some View {
        layoutValue(key: LayoutDemoView.ActiveKey.self, value: isActive)
    }
}

struct LayoutDemoView {
    //struct MyLayout: Layout {
    //    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    //
    //    }
    //
    //    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    //
    //    }
    //}

    struct ActiveKey: LayoutValueKey {
        static var defaultValue = false
    }

    struct AlignmentBottomLayout: Layout {
        struct Catch {
            var activeIndex = 0
            var sizes: [CGSize] = []

            var alignmentHeight: CGFloat {
                guard !sizes.isEmpty else { return .zero }
                return sizes[0...activeIndex].map { $0.height }.reduce(0,+)
            }
        }

        func makeCache(subviews: Subviews) -> Catch {
            .init()
        }

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Catch) -> CGSize {
            guard !subviews.isEmpty else { return .zero }
            var height: CGFloat = .zero
            for i in subviews.indices {
                let subview = subviews[i]
//                if subview[ActiveKey.self] == true {
//                    cache.activeIndex = i
//                }
                let viewDimension = subview.dimensions(in: proposal)
                height += viewDimension.height
                cache.sizes.append(.init(width: viewDimension.width, height: viewDimension.height))
            }
            return .init(width: proposal.replacingUnspecifiedDimensions().width, height: proposal.replacingUnspecifiedDimensions().height)
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Catch) {
            guard !subviews.isEmpty else { return }
            var currentY: CGFloat = bounds.height - cache.alignmentHeight + bounds.minY
            for i in subviews.indices {
                let subview = subviews[i]
                subview.place(at: .init(x: bounds.minX, y: currentY), anchor: .topLeading, proposal: proposal)
                currentY += cache.sizes[i].height
            }
        }
    }

    struct MyLayout: Layout {
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            .zero
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            subviews.forEach { v in
                v.place(at: CGPoint.zero, anchor: .center, proposal: .infinity)
            }
        }
    }

}

struct MyLayoutDemo: View {
    var body: some View {
        LayoutDemoView.MyLayout() {
            RedView()
            GreenView()
        }
    }
}

struct RedView: View {
    var body: some View {
        Rectangle()
            .fill(.red)
            .frame(height: 600)
    }
}

// View2
struct GreenView: View {
    var body: some View {
        Rectangle()
            .fill(.green)
            .frame(height: 600)
    }
}

// Switch Button
struct OverlayButton: View {
    @Binding var show: Bool
    var body: some View {
        Button(show ? "Hide" : "Show") {
            show.toggle()
        }
        .buttonStyle(.borderedProminent)
    }
}

extension View {
    func overlayButton(show: Binding<Bool>) -> some View {
        self
            .overlay(alignment: .bottom) {
                OverlayButton(show: show)
            }
    }
}

// get size of view
struct SizeInfoModifier: ViewModifier {
    @Binding var size: CGSize
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .task(id: proxy.size) {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func sizeInfo(_ size: Binding<CGSize>) -> some View {
        self
            .modifier(SizeInfoModifier(size: size))
    }
}
