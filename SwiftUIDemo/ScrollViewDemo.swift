//
//  ScrollViewDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2024/1/23.
//

import SwiftUI

struct ScrollViewDemo: View {
    let max = 50
    @State var isLoading = false
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                VStack(alignment:.leading) {
                    ScrollView(.vertical) {
                        ForEach(1...max, id: \.self) { num in
                            HStack {
                                Spacer()
                                Label(
                                    title: { Text("\(num)") },
                                    icon: { Image(systemName: "\(num).circle") }
                                )
                                Spacer()
                            }
                        }
                        Text("here").id(max)
                    }.redacted(reason: isLoading ? .placeholder : .privacy)
                    .navigationTitle("ScrollViewDemo")
                    Divider()
                    HStack {
                        Button("Reload") {
                            reload()
                        }
                        Button("Top") {
                            withAnimation {
                                proxy.scrollTo(1, anchor: .top)
                            }
                        }
                        Button("Middle") {
                            withAnimation {
                                proxy.scrollTo(max / 2, anchor: .center)
                            }
                        }
                        Button("Bottom") {
                            withAnimation {
                                proxy.scrollTo(max, anchor: .bottom)
                            }
                        }
                        Spacer()
                        ActivityIndicatorView(isShowing: isLoading, color: .red)
                        Menu {
                            Button {
                                reload()
                            } label: {
                                Text("Reload")
                            }
                            Button {
                                
                            } label: {
                                Text("Test")
                            }
                            Menu {
                                Button("Demo") {
                                    print("Demo")
                                }
                            } label: {
                                Text("Other")
                            }
                        } label: {
                            Text("More")
                        }
                    }
                }.padding().toolbar(content: {
                    ToolbarItem {
                        Menu {
                            Button {
                                reload()
                            } label: {
                                Text("Reload")
                            }
                            Button {
                                withAnimation {
                                    proxy.scrollTo(1, anchor: .top)
                                }
                            } label: {
                                Text("Top")
                            }
                            Button {
                                proxy.scrollTo(max / 2, anchor: .center)
                            } label: {
                                Text("Middle")
                            }
                            Button {
                                withAnimation {
                                    proxy.scrollTo(max, anchor: .bottom)
                                }
                            } label: {
                                Text("Bottom")
                            }
                            Menu {
                                Button {
                                    withAnimation {
                                        proxy.scrollTo(1, anchor: .top)
                                    }
                                } label: {
                                    Text("Top")
                                }
                                Button {
                                    proxy.scrollTo(max / 2, anchor: .center)
                                } label: {
                                    Text("Middle")
                                }
                                Button {
                                    withAnimation {
                                        proxy.scrollTo(max, anchor: .bottom)
                                    }
                                } label: {
                                    Text("Bottom")
                                }
                            } label: {
                                Text("More")
                            }
                        } label: {
                            Text("Menu")
                        }
                    }
                })
            }.onAppear() {
                reload()
            }
        }
    }
    
    func reload() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
}

#Preview {
    ScrollViewDemo()
}
