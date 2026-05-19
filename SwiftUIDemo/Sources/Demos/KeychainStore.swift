//
//  KeychainStore.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/29.
//

import SwiftUI

struct KeychainStoreDemo: View {
    @State var data: String = "wangxinghe"
    @State var retrievedData: String = ""
    @State var saveFailed = false
    @State var output: String = ""
    var body: some View {
        VStack {
            Text(data)
            Button("save") {
                let r = saveTokenToKeychain(token: data)
                output += "\n\(r ? "save success." : "save failed.")"
                if !r {
                    output += "\n \(updateTokenInKeychain(newToken: data) ? "updated succeed." : "updated failed.")"
                }
            }
            Button("retrieve") {
                retrievedData = loadTokenFromKeychain() ?? "load failed."
            }
            Text(retrievedData)
            Divider()
            Text(output)
            Spacer()
        }.alert(isPresented: $saveFailed, content: {
            Alert(title: Text("Save failed"))
        })
    }
    
    func saveTokenToKeychain(token: String) -> Bool {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "access_token",
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        print("saveStatus: \(status)")
        return status == errSecSuccess
    }

    func updateTokenInKeychain(newToken: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "access_token",
            kSecReturnAttributes as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { print("updating...failed. \(status)."); return false }
        guard let existingItem = item as? [String: Any] else { print("updating...failed. not found."); return false }
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "access_token",
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: newToken.data(using: .utf8)!
        ]
        let updateStatus = SecItemUpdate(existingItem as CFDictionary, updateQuery as CFDictionary)
        print("updateStatus: \(updateStatus)")
        return updateStatus == errSecSuccess
    }

    func loadTokenFromKeychain() -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "access_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)
        if status == errSecSuccess {
            return String(data: result as! Data, encoding: .utf8)
        } else {
            return nil
        }
    }
}

#Preview {
    KeychainStoreDemo()
}
