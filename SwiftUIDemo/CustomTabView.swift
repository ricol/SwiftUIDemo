//
//  CustomTabView.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2024/7/18.
//

import SwiftUI

enum Tab:String, CaseIterable {
    case offset, position, angle, globe
    
    func getText() -> String {
        return switch self {
        case .offset:
            "Offset"
        case .position:
            "Position"
        case .angle:
            "Angle"
        case .globe:
            "Undefine"
        }
    }
    func getImage() -> String {
        return switch self {
        case .offset:
            "house"
        case .position:
            "location"
        case .angle:
            "ticket"
        case .globe:
            "globe"
        }
    }
}

struct CustomTabView: View {
    @Binding var currentTab: Tab
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Button {
                        withAnimation {
                            currentTab = tab
                        }
                    } label: {
                        VStack {
                            Image(systemName: tab.getImage()).renderingMode(.template).frame(maxWidth: .infinity)
                                .foregroundStyle(Color.red).offset(y: currentTab == tab ? -18 : -8)
                            Text(tab.getText().capitalized).foregroundStyle(.red).font(.caption)
                        }
                    }
                }
            }.frame(maxWidth: .infinity)
        }.frame(height: 24).padding(.top, 30).background(.ultraThinMaterial)
    }
}

struct BackgroundAnimationView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle().foregroundColor(.blue).blur(radius: animate ? 30 : 100)
                .offset(x: animate ? -50 : -130, y: animate ? -30 : -100)
                .task {
                    withAnimation(.easeInOut(duration: 5).repeatForever()) {
                        animate.toggle()
                    }
                }
            Circle().foregroundColor(.red).blur(radius: animate ? 30 : 100)
                .offset(x: animate ? 100 : 130, y: animate ? 150 : 100)
        }
    }
}

struct MainView: View {
    @State private var currentTab: Tab = .position
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            VStack(spacing: 0) {
                TabView(selection: $currentTab,
                        content:  {
                    OffsetDemoView().tag(Tab.offset)
                    PositionDemoView().tag(Tab.position)
                    AngleDemoView().tag(Tab.angle)
                    UnDefinedDemoView().tag(Tab.globe)
                })
                CustomTabView(currentTab: $currentTab)
            }.background(.clear)
        }
    }
}

fileprivate struct OffsetDemoView: View {
    @GestureState private var isDragging = false
    @StateObject var model: MyImages = {
        var model = MyImages()
        var index = 0
        for image in Constants.liusisi {
            model.images.append(MyImage(image: Image(uiImage: image), angle: Double.random(in: 1...30), offset: CGSize(width: Int.random(in: -100...100), height: Int.random(in: (-100...100))), index: index))
            index += 1
        }
        return model
    }()
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            VStack {
                ZStack {
                    Group {
                        ForEach(model.images, id: \.id) { image in
                            SingleImageView(model: image).onTapGesture {
                                withAnimation {
                                    image.angle = Double.random(in: -100...100)
                                    image.offset = CGSize(width: Int.random(in: -100...100), height: Int.random(in: -100...100))
                                    image.index = MyImage.maxIndex(value: image.index)
                                }
                            }
                        }
                    }.frame(width: 300, height: 300)
                }
            }
        }
    }
}

fileprivate struct PositionDemoView: View {
    @StateObject var images: MyImages = {
        var images = MyImages()
        var index = 0
        let delta = 10.0
        var increase = true
        for image in Constants.liusisi {
            let myimage = MyImage(image: Image(uiImage: image), angle: 0, offset: .zero, position: CGPoint(x: 150, y: 150), index: index)
            images.images.append(myimage)
            index += 1
        }
        return images
    }()
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            ForEach(images.images, id: \.id) { image in
                SingleImageView(model: image).frame(width: 300, height: 300)
                    .gesture(DragGesture().onChanged({ value in
                        image.index = MyImage.maxIndex(value: image.index)
                    withAnimation {
                        if let pos = image.originalPos {
                            image.position = CGPoint(x: value.translation.width + pos.x, y: value.translation.height + pos.y)
                        }
                    }
                }).onEnded({ value in
                    image.originalPos = image.position
                })).zIndex(Double(image.index))
            }
        }
    }
}

fileprivate struct AngleDemoView: View {
    @StateObject var images: MyImages = {
        var images = MyImages()
        var index = 0
        var angle = -30.0
        let delta = 10.0
        var increase = true
        for image in Constants.liusisi {
            let myimage = MyImage(image: Image(uiImage: image), angle: angle, offset: .zero, position: CGPoint(x: 150, y: 150), index: index)
            images.images.append(myimage)
            if increase {
                angle += delta
            }else {
                angle -= delta
            }
            if angle > 30 { increase = false }
            if angle < -30 { increase = true }
            index += 1
        }
        return images
    }()
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            ForEach(images.images, id: \.id) { image in
                SingleImageView(model: image).frame(width: 300, height: 300)
                    .gesture(DragGesture().onChanged({ value in
                        image.index = MyImage.maxIndex(value: image.index)
                    withAnimation {
                        if let pos = image.originalPos {
                            image.position = CGPoint(x: value.translation.width + pos.x, y: value.translation.height + pos.y)
                        }
                    }
                }).onEnded({ value in
                    image.originalPos = image.position
                })).zIndex(Double(image.index))
            }
        }
    }
}

fileprivate struct UnDefinedDemoView: View {
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            Text("Globe")
        }
    }
}

#Preview {
    MainView()
}


fileprivate class MyImage: Identifiable, ObservableObject {
    let id: String = UUID().uuidString
    let image: Image
    var originalPos: CGPoint?
    static var maxIndex: Int = 0
    @Published var offset: CGSize
    @Published var position: CGPoint?
    @Published var angle: Double
    @Published var index: Int {
        didSet {
            if self.index > Self.maxIndex { Self.maxIndex = self.index }
        }
    }
    
    init(image: Image, angle: Double, offset: CGSize = .zero, position: CGPoint? = nil, index: Int = 0) {
        self.image = image
        self.angle = angle
        self.offset = offset
        self.index = index
        self.position = position
        self.originalPos = position
    }
    
    static func maxIndex(value: Int) -> Int {
        if value < Self.maxIndex { return Self.maxIndex + 1 }
        return value
    }
}

fileprivate class MyImages: ObservableObject {
    @Published var images: [MyImage] = []
}

fileprivate struct SingleImageView: View {
    @ObservedObject var model: MyImage
    var body: some View {
        model.image.resizable().aspectRatio(contentMode: .fit).zIndex(Double(model.index)).rotationEffect(Angle(degrees: model.angle)).offset(model.offset).updatePosition(model.position).shadow(radius: 20)
    }
}

extension View {
    
    func updatePosition(_ pos: CGPoint?) -> some View {
        Group {
            if let pos {
                self.position(pos)
            }else { self }
        }
    }
}
