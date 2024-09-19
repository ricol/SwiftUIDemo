//
//  FormDemoView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/13.
//

import SwiftUI

struct FormDemo: View {
    @StateObject var p = PersonDetail()
    @FocusState var focusedTF: Focused?
    @State var destination: Int?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    Label {
                        TextField("firstname", text: $p.firstname).focused($focusedTF, equals: .firstname)
                    } icon: {
                        Image(systemName: "pencil")
                    }
                    Label {
                        TextField("lastname", text: $p.lastname).focused($focusedTF, equals: .lastname)
                    } icon: {
                        Image(systemName: "pencil")
                    }
                    Label {
                        TextField("email", text: $p.email).keyboardType(.emailAddress).focused($focusedTF, equals: .email)
                    } icon: {
                        Image(systemName: "envelope.fill")
                    }
                    Label {
                        DatePicker("Birthday", selection: $p.dob, displayedComponents: .date)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }.autocorrectionDisabled().keyboardType(.namePhonePad).autocapitalization(.none)
                Section("Summary") {
                    Label {
                        Text((p.firstname + " " + p.lastname).capitalized)
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                    Label {
                        Text(p.email)
                    } icon: {
                        Image(systemName: "envelope.fill")
                    }
                    
                }
                Section("Action") {
                    NavigationLink {
                        DetailsView(p: p)
                    } label: {
                        Label {
                            Text("Submit")
                        } icon: {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    
                }
            }.navigationTitle("Form").toolbar {
                Button("Clear") {
                    p.clear()
                }
            }
        }.background(.blue).ignoresSafeArea()
        DetailsView(p: p)
    }
    
    struct DetailsView: View {
        @ObservedObject var p: PersonDetail
        
        var body: some View {
            VStack {
                Text("Name: " + (p.firstname + " " + p.lastname).capitalized)
                Text("Email: \(p.email)")
            }.font(.title2).padding()
        }
    }
    
    enum Focused {
        case firstname, lastname, email
    }

    class PersonDetail: ObservableObject {
        @AppStorage("firstname") var firstname: String = ""
        @AppStorage("lastname") var lastname: String = ""
        @AppStorage("email") var email: String = ""
        @Published var dob: Date = Date()
        
        func clear() {
            firstname = ""
            lastname = ""
            email = ""
        }
    }
}

#Preview {
    FormDemo()
}
