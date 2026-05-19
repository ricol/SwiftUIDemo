//
//  ImagesView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/4/7.
//

import SwiftUI

fileprivate struct MyImage: Identifiable, Hashable {
    let image: UIImage
    let id = UUID()
}

fileprivate class ImagesViewModel: ObservableObject {
    @Published var images = [MyImage]()
    
    func loadImages() async {
        if images.count > 0 { return }
        await loadImagesWithTaskGroup()
//        await loadImagesWithDetachedTask()
//        await loadImagesWithCompletionHandleInTask()
    }
    
    func loadImagesWithTaskGroup() async {
        print("loadImagesWithTaskGroup...")
        do {
            try await withThrowingTaskGroup(of: UIImage?.self, body: { group in
                if let path = Bundle.main.path(forResource: "liusisi", ofType: "bundle"), let bundle = Bundle(path: path)  {
                    if let contents = try? FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil) {
                        for c in contents {
                            group.addTask {
                                return try await self.loadImage(path: c.lastPathComponent, from: bundle)
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
        }catch {
            print("exception: \(error)")
        }
    }
    
    func loadImagesWithDetachedTask() async {
        print("loadImagesWithDetachedTask...")
        if let path = Bundle.main.path(forResource: "liusisi", ofType: "bundle"), let bundle = Bundle(path: path)  {
            if let contents = try? FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil) {
                for c in contents {
                    //a detached task won't cancel if parent task cancelled
                    Task {
                        do {
                            if let image = try await self.loadImage(path: c.lastPathComponent, from: bundle) {
                                await MainActor.run {
                                    self.images.append(MyImage(image: image))
                                }
                            }
                        }catch {
                            //no exception when the parent task is cancelled!
                            print("exception: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func loadImagesWithCompletionHandleInTask() async {
        print("loadImagesWithCompletionHandleInTask...")
        if let path = Bundle.main.path(forResource: "liusisi", ofType: "bundle"), let bundle = Bundle(path: path)  {
            if let contents = try? FileManager.default.contentsOfDirectory(at: bundle.bundleURL, includingPropertiesForKeys: nil) {
                for c in contents {
                    do {
                        async let w = loadImage(path: c.lastPathComponent, from: bundle, complete: { image in
                            if let image {
                                DispatchQueue.main.async {
                                    self.images.append(MyImage(image: image))
                                }
                            }
                        })
                        //above loadImage won't start to run until await!
                        let _ = try await w
                    }catch {
                        print("exception: \(error)")
                    }
                }
            }
        }
    }
    
    private func loadImage(path: String, from bundle: Bundle, complete: ((UIImage?) -> Void)? = nil) async throws -> UIImage? {
        print("loading image ...\(path)")
        try Task.checkCancellation()
        let n = (1...10).randomElement()!
        print("loading image ...\(path) wait for \(n)")
        try await Task.sleep(nanoseconds: UInt64(Double(n) * 1e9))
        try Task.checkCancellation()
        let image = UIImage(named: path, in: bundle, with: nil)
        try Task.checkCancellation()
        print("loading image ...\(path) complete.")
        try Task.checkCancellation()
        if let complete {
            print("running complete...")
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

struct ImageDetailView: View {
    @State var image: UIImage
    var body: some View {
        ScrollView {
            Image(uiImage: image).resizable().scaledToFit()
        }.navigationTitle("Image Detail")
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
                                ImageDetailView(image: n.image)
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
                            ImageDetailView(image: n.image)
                        } label: {
                            Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                        }
                    }
                })
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(vm.images) { n in
                            NavigationLink {
                                ImageDetailView(image: n.image)
                            } label: {
                                Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                            }
                        }
                    }
                }
            }.task {
                await vm.loadImages()
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
                            ImageDetailView(image: n.image)
                        } label: {
                            Image(uiImage: n.image).resizable().scaledToFit().frame(width: 100, height: 100)
                        }
                    }
                }).task {
                    await vm.loadImages()
                }
            }.navigationTitle("Liu sisi").navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainImagesView()
}
