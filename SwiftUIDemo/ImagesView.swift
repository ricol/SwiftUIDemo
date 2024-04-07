//
//  ImagesView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/4/7.
//

import SwiftUI

struct MyImage: Identifiable, Hashable {
    let image: UIImage
    let id = UUID()
}

class ImagesViewModel: ObservableObject {
    @Published var images = [MyImage]()
    
    func loadImages() async throws {
        if images.count > 0 { return }
        try await withThrowingTaskGroup(of: UIImage?.self, body: { group in
            if let path = Bundle.main.path(forResource: "liusisi", ofType: "bundle"), let bundle = Bundle(path: path)  {
                if let contents = try? FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil) {
                    for c in contents {
                        group.addTask {
                            do {
                                return try await self.loadImage(path: c.lastPathComponent, from: bundle)
                            }catch {
                                print("exception: \(error)")
                                return nil
                            }
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.images = [MyImage]()
            }
            for try await image in group {
                if let image {
                    try Task.checkCancellation()
                    await MainActor.run {
                        self.images.append(MyImage(image: image))
                    }
                }
            }
        })
        /*
        if let path = Bundle.main.path(forResource: "liusisi", ofType: "bundle"), let bundle = Bundle(path: path)  {
            if let contents = try? FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil) {
                print("contents: \(contents)")
                var images = [UIImage]()
                for c in contents {
                    Task.detached {
                        if let image = await self.loadImage(path: c.lastPathComponent, from: bundle) {
                            await MainActor.run {
                                self.images.append(image)
                            }
                        }
                    }
                    async let _ = loadImage(path: c.lastPathComponent, from: bundle, complete: { image in
                        if let image {
                            DispatchQueue.main.async {
                                self.images.append(image)
                            }
                        }
                    })
                }
            }
        }
         */
    }
    
    func loadImage(path: String, from bundle: Bundle, complete: ((UIImage?) -> Void)? = nil) async throws -> UIImage? {
        try Task.checkCancellation()
        print("loading image ...\(path)")
        let n = (1...10).randomElement()!
        try await Task.sleep(nanoseconds: UInt64(Double(n) * 1e9))
        try Task.checkCancellation()
        let image = UIImage(named: path, in: bundle, with: nil)
        try Task.checkCancellation()
        print("loading image ...\(path) complete.")
        try Task.checkCancellation()
        if let complete {
            complete(image)
            return image
        }
        return image
    }
}

struct MainImagesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    ImagesView()
                } label: {
                    Text("Liusisi - Grid View")
                }
                
                NavigationLink {
                    ImagesViewScroll()
                } label: {
                    Text("Liusisi - Scroll View")
                }
            }
        }
    }
}

struct ImagesViewScroll: View {
    @StateObject private var vm = ImagesViewModel()
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(vm.images) { n in
                            NavigationLink {
                                Image(uiImage: n.image).resizable().scaledToFit().navigationTitle("Image Detail")
                            } label: {
                                Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                            }
                        }
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible(minimum: 50, maximum: 100)),
                                    GridItem(.flexible(minimum: 50, maximum: 100)),
                                    GridItem(.flexible(minimum: 50, maximum: 100))], content: {
                    ForEach(vm.images, id: \.self) { n in
                        NavigationLink {
                            Image(uiImage: n.image).resizable().scaledToFit().navigationTitle("Image Detail")
                        } label: {
                            Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                        }
                    }
                })
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(vm.images) { n in
                            NavigationLink {
                                Image(uiImage: n.image).resizable().scaledToFit().navigationTitle("Image Detail")
                            } label: {
                                Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                            }
                        }
                    }
                }
            }.task {
                try? await vm.loadImages()
            }.navigationTitle("Liu SiSi")
        }
    }
}

struct ImagesView: View {
    @StateObject private var vm = ImagesViewModel()
    @State var task: Task<(), Error>? = nil
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: [GridItem(.flexible(minimum: 50, maximum: 100)),
                                    GridItem(.flexible(minimum: 50, maximum: 100)),
                                    GridItem(.flexible(minimum: 50, maximum: 100))], content: {
                    ForEach(vm.images, id: \.self) { n in
                        NavigationLink {
                            Image(uiImage: n.image).resizable().scaledToFit().navigationTitle("Image Detail")
                        } label: {
                            Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                        }
                    }
                }).task {
                    do {
                        try await vm.loadImages()
                    }catch {
                        print("exception: \(error)")
                    }
                }
            }.navigationTitle("Liu sisi").navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainImagesView()
}
