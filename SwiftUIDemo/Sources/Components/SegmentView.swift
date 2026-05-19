//
//  SegmentView.swift
//  EfektaMobile
//
//  Created by Tomas Shao on 2026/4/13.
//  Copyright © 2026 EF. All rights reserved.
//

import SwiftUI

/// A brand segmented control where every segment occupies equal width.
///
/// The selected segment title is rendered in **textPrimary / labelBold** with a
/// 3 pt `efBlack` underline; unselected segments use **gray4 / labelBold** with a
/// 3 pt `gray4` underline. Switching segments animates the underline via
/// `matchedGeometryEffect`.
///
/// ### Generic usage
/// ```swift
/// @State private var tab = "Schedule"
///
/// SegmentView(selection: $tab) {
///     Text("Overview").tag(segment: "Overview")
///     Text("Schedule").tag(segment: "Schedule")
///     Text("Members").tag(segment: "Members")
/// }
/// ```
///
/// ### Convenience string-array usage
/// ```swift
/// @State private var index = 0
///
/// SegmentView(titles: ["Overview", "Schedule", "Members"], selection: $index)
/// ```
struct SegmentView<SelectionValue: Hashable>: View {
    private let items: [SegmentItem<SelectionValue>]
    @Binding private var selection: SelectionValue
    @Namespace private var underline

    private init(
        items: [SegmentItem<SelectionValue>],
        selection: Binding<SelectionValue>
    ) {
        self.items = items
        self._selection = selection
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                segmentButton(for: item)
            }
        }
    }

    @ViewBuilder
    private func segmentButton(for item: SegmentItem<SelectionValue>) -> some View {
        let isSelected = selection == item.id

        Button {
            guard selection != item.id else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = item.id
            }
        } label: {
            VStack(spacing: 0) {
                item.label
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .black : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 2)

                // Underline indicator
                ZStack {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: 3)

                    if isSelected {
                        Rectangle()
                            .fill(.black)
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "underline", in: underline)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

// MARK: - Private item model

private struct SegmentItem<SelectionValue: Hashable>: Identifiable {
    let id: SelectionValue
    let label: AnyView

    init<Label: View>(tag: SelectionValue, label: Label) {
        self.id = tag
        self.label = AnyView(label)
    }
}

// MARK: - tag(segment:) modifier

/// Associates a tag value with a view so that `SegmentView` can identify it.
///
/// **Why not use SwiftUI's native `.tag(_:)`?**
/// The native `.tag(_:)` returns `some View` (an opaque, type-erased result).
/// `SegmentBuilder.buildBlock` needs a concrete `SegmentTaggedView<Tag, Content>`
/// so the compiler can statically extract the tag at build time.
/// Because the return types differ, using native `.tag(_:)` here would cause
/// a type mismatch and the builder would fail to compile.
extension View {
    func tag<V: Hashable>(segment tag: V) -> SegmentTaggedView<V, Self> {
        SegmentTaggedView(tag: tag, content: self)
    }
}

/// A view that carries a segment tag. Pass it directly inside `SegmentView { … }`.
struct SegmentTaggedView<Tag: Hashable, Content: View>: View {
    let tag: Tag
    let content: Content

    var body: some View { content }
}

// MARK: - @resultBuilder for SegmentView content

@resultBuilder
enum SegmentBuilder<SelectionValue: Hashable> {
    static func buildBlock<each V: View>(
        _ items: repeat SegmentTaggedView<SelectionValue, each V>
    ) -> [SegmentTaggedView<SelectionValue, AnyView>] {
        var result: [SegmentTaggedView<SelectionValue, AnyView>] = []
        repeat result.append(SegmentTaggedView(tag: (each items).tag, content: AnyView((each items).content)))
        return result
    }
}

// MARK: - Initializers

extension SegmentView {
    /// Creates a segment view from a `@ViewBuilder` block of `tag(segment:)`-annotated views.
    ///
    /// ```swift
    /// SegmentView(selection: $tab) {
    ///     Text("Overview").tag(segment: "Overview")
    ///     Text("Schedule").tag(segment: "Schedule")
    /// }
    /// ```
    init(
        selection: Binding<SelectionValue>,
        @SegmentBuilder<SelectionValue> content: () -> [SegmentTaggedView<SelectionValue, AnyView>]
    ) {
        let items = content().map { SegmentItem(tag: $0.tag, label: $0.content) }
        self.init(items: items, selection: selection)
    }
}

extension SegmentView where SelectionValue == Int {
    /// Creates a segment view from plain strings, using `Int` indices as selection values.
    ///
    /// ```swift
    /// @State private var index = 0
    /// SegmentView(titles: ["Overview", "Schedule", "Members"], selection: $index)
    /// ```
    init(titles: [String], selection: Binding<Int>) {
        let items = titles.enumerated().map { index, title in
            SegmentItem<Int>(tag: index, label: Text(title))
        }
        self.init(items: items, selection: selection)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var indexSelection = 0
        @State private var stringSelection = "Schedule"

        var body: some View {
            VStack(spacing: 16) {
                SegmentView(
                    titles: ["Overview", "Schedule", "Members"],
                    selection: $indexSelection
                )

                SegmentView(selection: $stringSelection) {
                    Text("Overview").tag(segment: "Overview")
                    Text("Schedule").tag(segment: "Schedule")
                    Text("Members").tag(segment: "Members")
                }

                SegmentView(
                    titles: ["Private Class", "Group Classes"],
                    selection: $indexSelection
                )

                SegmentView(selection: $stringSelection) {
                    Text("My Current Booking").tag(segment: "Overview")
                    Text("Group Classes").tag(segment: "Schedule")
                }

                SegmentView(
                    titles: ["AI Conversation", "Private Classes", "Group Classes"],
                    selection: $indexSelection
                )

                SegmentView(selection: $stringSelection) {
                    Text("AI Conversations").tag(segment: "Overview")
                    Text("Private Classes").tag(segment: "Schedule")
                    Text("Group Classes").tag(segment: "Members")
                }

                Spacer()
            }.padding()
        }
    }

    return PreviewWrapper()
}
