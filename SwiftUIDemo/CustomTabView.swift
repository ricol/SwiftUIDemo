//
//  CustomTabView.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2024/7/18.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case house, location, ticket, globe
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
                            Image(systemName: tab.rawValue).renderingMode(.template).frame(maxWidth: .infinity)
                                .foregroundStyle(Color.red).offset(y: currentTab == tab ? -18 : -8)
                            Text(tab.rawValue.capitalized).foregroundStyle(.red).font(.caption)
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
    @State private var currentTab: Tab = .house
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            VStack(spacing: 0) {
                TabView(selection: $currentTab,
                        content:  {
                    HouseView().tag(Tab.house)
                    LocationView().tag(Tab.location)
                    TicketView().tag(Tab.ticket)
                    GlobeView().tag(Tab.globe)
                })
                CustomTabView(currentTab: $currentTab)
            }.background(.clear)
        }
    }
}

fileprivate struct HouseView: View {
    @GestureState private var isDragging = false
    @StateObject var images: MyImages = {
        var images = MyImages()
        var index = 0
        for image in Constants.liusisi {
            images.images.append(MyImage(image: Image(uiImage: image), degree: Double.random(in: 1...30), offset: CGSize(width: Int.random(in: -100...100), height: Int.random(in: (-100...100))), index: index))
            index += 1
        }
        return images
    }()
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            VStack {
                ZStack {
                    Group {
                        ForEach(images.images, id: \.id) { image in
                            SingleImageView(image: image).onTapGesture {
                                withAnimation {
                                    image.degree = Double.random(in: -100...100)
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

fileprivate struct SingleImageView: View {
    @ObservedObject var image: MyImage
    var body: some View {
        VStack {
            image.image.resizable().aspectRatio(contentMode: .fit)
//            Text("ZIndex: \(image.index)")
        }.rotationEffect(Angle(degrees: image.degree)).offset(image.offset).zIndex(Double(image.index))
    }
}

fileprivate struct LocationView: View {
    @StateObject var images: MyImages = {
        var images = MyImages()
        var index = 0
        var degree = -30.0
        let delta = 10.0
        var increase = true
        for image in Constants.liusisi + Constants.liusisi {
            let myimage = MyImage(image: Image(uiImage: image), degree: degree, offset: .zero, index: index)
            images.images.append(myimage)
            if increase {
                degree += delta
            }else {
                degree -= delta
            }
            if degree > 30 { increase = false }
            if degree < -30 { increase = true }
            index += 1
        }
        return images
    }()
    
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            VStack {
                ZStack {
                    Group {
                        ForEach(images.images, id: \.id) { image in
                            SingleImageView(image: image).gesture(DragGesture().onChanged({ value in
                                withAnimation {
                                    image.offset = value.translation
                                }
                            }).onEnded({ value in
                                withAnimation {
                                    image.offset = .zero
                                }
                            }))
                        }
                    }.frame(width: 300, height: 300)
                }
            }
        }
    }
}

struct TicketView: View {
    var body: some View {
        ZStack {
            BackgroundAnimationView()
            Text("Ticket")
        }
    }
}

struct GlobeView: View {
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
    static var maxIndex: Int = 0
    @Published var offset: CGSize
    @Published var degree: Double
    @Published var index: Int {
        didSet {
            if self.index > Self.maxIndex { Self.maxIndex = self.index }
        }
    }
    
    init(image: Image, degree: Double, offset: CGSize, index: Int) {
        self.image = image
        self.degree = degree
        self.offset = offset
        self.index = index
    }
    
    static func maxIndex(value: Int) -> Int {
        if value < Self.maxIndex { return Self.maxIndex + 1 }
        return value
    }
}

fileprivate class MyImages: ObservableObject {
    @Published var images: [MyImage] = []
}
