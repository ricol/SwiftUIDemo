//
//  AnimationView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/1.
//

import SwiftUI

struct EmployeeView: View {
    var employee: Employee = Employee(name: "ricol wang", jobTitle: "Mobile App Developer", emailAddress: "ricolwang2020@gmail.com", profilePictures: "profile")
    
    var body: some View {
        HStack {
            ProfilePicture(imageName: employee.profilePictures)
            EmployeeDetails(employee: employee)
        }
    }
    
    struct Employee {
        var name: String
        var jobTitle: String
        var emailAddress: String
        var profilePictures: String
    }

    struct ProfilePicture: View {
        var imageName: String
        
        var body: some View {
            Image(imageName).resizable().frame(width: 100, height: 100).clipShape(Circle())
        }
    }

    struct EmailAddress: View {
        var address: String
        
        var body: some View {
            HStack {
                Image(systemName: "envelope")
                Text(address)
            }
        }
    }

    struct EmployeeDetails: View {
        var employee: Employee
        
        var body: some View {
            VStack(alignment: .leading, content: {
                Text(employee.name.capitalized).font(.largeTitle).foregroundStyle(.primary)
                Text(employee.jobTitle).foregroundStyle(.secondary)
                EmailAddress(address: employee.emailAddress)
            })
        }
    }
}

struct SearchField: UIViewRepresentable {
    @Binding var text: String

    private var placeholder = ""

    init(text: Binding<String>) {
        _text = text
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = placeholder
        return searchBar
    }

    // Always copy the placeholder text across on update
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder
    }
}

extension SearchField {
    func placeholder(_ string: String) -> SearchField {
        var view = self
        view.placeholder = string
        return view
    }
}

struct SearchFieldDemoView: View {
    @State private var text = ""
    @State private var placeHolder = "Hello, world!"

    var body: some View {
        VStack {
            SearchField(text: $text).placeholder(placeHolder)
            Button("Tap me") {
                // randomize the placeholder every press, to
                // prove this works
                placeHolder = UUID().uuidString
            }
        }
    }
}
#Preview {
    EmployeeView()
}

#Preview {
    SearchFieldDemoView()
}

struct ActivityIndicatorView: UIViewRepresentable {
    var isShowing: Bool
    var color: UIColor

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView()
        a.color = color
        return a
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isShowing ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
    typealias UIViewType = UIActivityIndicatorView
}

#Preview {
    ActivityIndicatorView(isShowing: true, color: .red)
}
