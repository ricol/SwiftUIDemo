//
//  AsyncActorDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/23.
//

import SwiftUI

actor Account: ObservableObject {
    @Published var balance: Int = 0
    
    func deposit(cash: Int) {
        balance += cash
    }
    
    func withdraw(cash: Int) {
        balance -= cash
    }
    
    func getBalance() -> Int {
        balance
    }
}

struct AsyncActorDemo: View {
    var account: Account = Account()
    @State var b: Int = 0
    var body: some View {
        VStack {
            Text("\(b)")
            Spacer()
            Divider()
            HStack {
                Button("Add") {
                    (0...100).forEach { e in
                        Task {
                            await account.deposit(cash: e)
                        }
                    }
                }
                Button("Remove") {
                    (0...100).forEach { e in
                        Task {
                           await account.withdraw(cash: e)
                        }
                    }
                }
                Button("Result") {
                    Task {
                        b = await account.getBalance()
                    }
                }
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    AsyncActorDemo()
}
