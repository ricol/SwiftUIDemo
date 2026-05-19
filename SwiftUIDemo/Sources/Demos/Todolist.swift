//
//  ContentView.swift
//  Todolist
//
//  Created by Ricol Wang on 2024/2/14.
//

import SwiftUI

struct UserRecord: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var password: String
}

@Observable
fileprivate class Task: NSObject, Identifiable, Codable, ObservableObject {
    var id = UUID()
    var title: String?
    var desc: String?
    var isComplete: Bool = false
    var dueDate: Date?
    var fmtDate: String {
        let fm = DateFormatter()
        fm.dateStyle = .short
        fm.timeStyle = .long
        return fm.string(from: dueDate ?? Date())
    }
}

@Observable
class TodolistViewModel {
    var navTarget: NavigationTarget = .login
    var accounts = [UserRecord]()
    fileprivate var tasks = [Task]()
    var currentUser: UserRecord? {
        didSet {
            if let n = currentUser?.name, let data = UserDefaults.standard.value(forKey: "\(n)") as? Data {
                if let records = try? JSONDecoder().decode([Task].self, from: data) {
                    tasks = records
                    print("tasks loaded.")
                }
            }else {
                tasks = [Task]()
            }
        }
    }
    var islogin: Bool {
        currentUser != nil
    }
    
    init() {
        loadAccounts()
    }
    
    func login(name: String, password: String) {
        for r in accounts {
            if r.name == name && r.password == password {
                currentUser = UserRecord(name: name, password: password)
                return
            }
        }
        print("isLogin: \(islogin)")
    }
    
    func signup(name: String, password: String) -> Bool {
        var exist = false
        for r in accounts {
            if r.name == name && r.password == password { exist = true; break }
        }
        if !exist {
            accounts.append(UserRecord(name: name, password: password))
            if let data = try? JSONEncoder().encode(accounts) {
                UserDefaults.standard.set(data, forKey: "accounts")
            }
            print("accounts: \(accounts)")
        }else { return false }
        return true
    }
    
    func saveTasks() {
        if let n = currentUser?.name, let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: n)
            print("tasks saved.")
        }
    }
    
    func loadAccounts() {
        if let data = UserDefaults.standard.value(forKey: "accounts") as? Data {
            if let records = try? JSONDecoder().decode([UserRecord].self, from: data) {
                accounts = records
                print("accounts loaded.")
            }else {
                accounts = [UserRecord]()
            }
        }
    }
    
    func saveAccounts() {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: "accounts")
            print("accounts saved.")
        }
    }
    
    func logout() {
        currentUser = nil
    }
}

struct LoginView: View {
    @Environment(TodolistViewModel.self) var vm
    @State var name: String = ""
    @State var password: String = ""
    @State var msg: String = ""
    var body: some View {
        VStack {
            Form {
                Section("Enter your account", content: {
                    TextField("name", text: $name).autocorrectionDisabled().textInputAutocapitalization(.never)
                    SecureField("password", text: $password).autocorrectionDisabled().textInputAutocapitalization(.never)
                })
                Button("Login") {
                    vm.login(name: name, password: password)
                    msg = vm.islogin ? "" : "login failed!"
                }
                NavigationLink {
                    SignupView()
                } label: {
                    Text("Signup")
                }
                NavigationLink {
                    List {
                        ForEach(vm.accounts, id: \.self) { account in
                            Text("username: \(account.name), password: \(account.password)").swipeActions() {
                                Button("Delete") {
                                    vm.accounts.remove(at: vm.accounts.firstIndex(of: account)!)
                                    vm.saveAccounts()
                                }
                            }
                        }
                    }.navigationTitle("User management").onAppear() {
                        vm.loadAccounts()
                    }
                } label: {
                    Text("User Managerment")
                }
                if !msg.isEmpty {
                    Section() {
                        Text(msg).foregroundStyle(.red)
                    }
                }
            }.background(.clear)
        }.background(.clear).navigationTitle("Login")
    }
}

struct SignupView: View {
    @Environment(TodolistViewModel.self) var vm
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var password: String = ""
    @State var confirm: String = ""
    @State var msg: String = ""
    var body: some View {
        Form {
            Section("New Account") {
                TextField("name", text: $name).autocorrectionDisabled().textInputAutocapitalization(.never)
                SecureField("password", text: $password).autocorrectionDisabled().textInputAutocapitalization(.never)
                SecureField("confirm", text: $confirm).autocorrectionDisabled().textInputAutocapitalization(.never)
            }
            Button("Signup") {
                if password.isEmpty || confirm.isEmpty || name.isEmpty || password != confirm { msg = "invalid format"; return }
                let result = vm.signup(name: name, password: password)
                if !result {
                    msg = "Sign up failed"
                }else {
                    dismiss()
                }
            }
            if !msg.isEmpty {
                Section() {
                    Text(msg).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Signup")
    }
}

enum NavigationTarget: Hashable {
    case login, signup, main
}

struct Todolist: View {
    @Environment(TodolistViewModel.self) var vm
    var body: some View {
        NavigationStack {
            if vm.islogin {
                TodoListMainView()
            }else {
                LoginView()
            }
        }
    }
}

struct TodoListMainView: View {
    @Environment(TodolistViewModel.self) var vm
    @State var showAddView = false
    var body: some View {
        Group {
            if vm.tasks.count > 0 {
                List {
                    ForEach(vm.tasks, id: \.self) { task in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(task.title ?? "")
                            Text(task.desc ?? "")
                            Text(task.fmtDate)
                            Toggle(isOn: Binding(get: {
                                task.isComplete
                            }, set: { v in
                                task.isComplete = v
                                vm.saveTasks()
                            })) {
                                Text("completed")
                            }
                        }.swipeActions() {
                            Button("Delete") {
                                if let index = vm.tasks.firstIndex(of: task) {
                                    vm.tasks.remove(at: index)
                                    vm.saveTasks()
                                }
                            }
                        }
                    }
                }
            }else {
                Text("no todo tasks.")
            }
        }
        .toolbar(content: {
            HStack {
                Button("Logout") {
                    vm.currentUser = nil
                }
                Spacer()
                Button("Add") {
                    showAddView.toggle()
                }
                Button("Clear") {
                    vm.tasks.removeAll()
                }
            }
        }).refreshable {
            vm.currentUser = vm.currentUser
        }.sheet(isPresented: $showAddView, content: {
            AddTodoListView(showAddView: $showAddView)
        }).navigationTitle("Todo List")
    }
}

struct AddTodoListView: View {
    @Environment(TodolistViewModel.self) var vm
    @Binding var showAddView: Bool
    @StateObject fileprivate var task: Task = Task()
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField(text: Binding(get: {
                        task.title ?? ""
                    }, set: { v in
                        task.title = v
                    })) {
                        Text("title")
                    }
                    TextField(text: Binding(get: {
                        task.desc ?? ""
                    }, set: { v in
                        task.desc = v
                    })) {
                        Text("description")
                    }
                    Toggle(isOn: $task.isComplete, label: {
                        Text("completed?")
                    })
                    Button("Save") {
                        task.dueDate = Date()
                        vm.tasks.append(task)
                        vm.saveTasks()
                        showAddView.toggle()
                    }
                }
            }.navigationTitle("Add new todo")
        }
    }
}

#Preview {
    Todolist().environment(TodolistViewModel())
}
