//
//  ResultBuilderDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/5/20.
//

import SwiftUI

@resultBuilder
struct StringBuilder {
    static func buildBlock(_ parts: String...) -> String {
        parts.map{"⭐️" + $0 + "🌈"}.joined(separator: " ")
    }
}

@resultBuilder
struct IntBuilder {
    static func buildArray(_ components: [Int]) -> Int {
        components.reduce(0) { partialResult, n in
            partialResult + n
        }
    }

    static func buildBlock(_ components: Int...) -> Int {
        buildArray(Array(components))
    }
}

@StringBuilder
func getStrings() -> String {
    "喜羊羊"
    "美羊羊"
    "灰太狼"
}

// ⭐️喜羊羊🌈 ⭐️美羊羊🌈 ⭐️灰太狼🌈

@IntBuilder
func getInt() -> Int {
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
}

@IntBuilder
func getInt(_ nums: [Int]) -> Int {
    for i in nums {
        i
    }
}

@resultBuilder
public enum AttributedStringBuilder {
    // Corresponding to the case where no component is used in the block
    public static func buildBlock() -> AttributedString {
        .init("")
    }

    // Corresponding to the case where n components (n is a positive integer) are used in the block
    public static func buildBlock(_ components: AttributedString...) -> AttributedString {
        components.reduce(into: AttributedString("")) { result, next in
            result.append(next)
        }
    }
}

@AttributedStringBuilder // Marked explicitly
var myFirstText: AttributedString {
    AttributedString("Hello")
    AttributedString("World")
}
// "HelloWorld"

@AttributedStringBuilder
func mySecondText() -> AttributedString {} // Empty block will call `buildBlock() -> AttributedString`
// ""

@AttributedStringBuilder
var myThirdText: AttributedString {
    AttributedString("Hello")
             .color(.red)
    AttributedString("World")
         .color(.blue)
         .bold()
}

// Marked on the API side
func generateText(@AttributedStringBuilder _ content: () -> AttributedString) -> Text {
    Text(content())
}

public extension AttributedString {
    func color(_ color: Color) -> AttributedString {
        then {
            $0.foregroundColor = color
        }
    }

    func bold() -> AttributedString {
        return then {
            if var inlinePresentationIntent = $0.inlinePresentationIntent {
                var container = AttributeContainer()
                inlinePresentationIntent.insert(.stronglyEmphasized)
                container.inlinePresentationIntent = inlinePresentationIntent
                let _ = $0.mergeAttributes(container)
            } else {
                $0.inlinePresentationIntent = .stronglyEmphasized
            }
        }
    }

    func italic() -> AttributedString {
        return then {
            if var inlinePresentationIntent = $0.inlinePresentationIntent {
                var container = AttributeContainer()
                inlinePresentationIntent.insert(.emphasized)
                container.inlinePresentationIntent = inlinePresentationIntent
                let _ = $0.mergeAttributes(container)
            } else {
                $0.inlinePresentationIntent = .emphasized
            }
        }
    }

    func then(_ perform: (inout Self) -> Void) -> Self {
        var result = self
        perform(&result)
        return result
    }
}

struct StringBuilderView: View {
    @State private var strResult: String = "Tap to show the result of string builder."
    @State private var intResultByBlock: Int = 0
    @State private var intResultByArray: Int = 0
    @State private var attributedStringResult1: AttributedString = "Tap to show attributed string"
    @State private var attributedStringResult2: AttributedString = "Tap to show attributed string"
    @State private var attributedStringResult3: AttributedString = "Tap to show attributed string"

    var body: some View {
        List {
            Section("String Builder") {
                VStack {
                    Text(strResult)
                    Button("Run") {
                        strResult = getStrings()
                    }
                }
            }
            Section("Int Builder (Block)") {
                VStack {
                    Text("\(intResultByBlock)")
                    Button("Run") {
                        intResultByBlock = getInt()
                    }
                }
            }
            Section("Int Builder (Array)") {
                VStack {
                    Text("\(intResultByArray)")
                    Button("Run") {
                        intResultByArray = getInt(Array(0...10))
                    }
                }
            }
            Section("AttributedString1") {
                VStack {
                    Text(attributedStringResult1)
                    Button("Run") {
                        attributedStringResult1 = myFirstText
                    }
                }
            }
            Section("AttributedString2") {
                VStack {
                    Text(attributedStringResult2)
                    Button("Run") {
                        attributedStringResult2 = mySecondText()
                    }
                }
            }
            Section("GenerateAttributedText") {
                generateText({
                    myFirstText
                })
            }
            Section("AttributedString3") {
                VStack {
                    Text(attributedStringResult3)
                    Button("Run") {
                        attributedStringResult3 = myThirdText
                    }
                }
            }
        }
    }
}

#Preview {
    StringBuilderView()
}
