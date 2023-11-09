//
//  MetadataStorage.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 6.11.2023.
//

import Foundation

public class MetadataStorage {
    
    private static let PREF_NAME = "musap"
    private static let SSCD_SET  = "sscd"
    
    /**
     * Set that contains all known key names
     */
    private static let KEY_NAME_SET = "keynames"
    private static let SSCD_ID_SET  = "sscdids"
    
    /**
     * Prefix that storage uses to store key-speficic metadata.
     */
    private static let KEY_JSON_PREFIX = "keyjson_"
    private static let SSCD_JSON_PREFIX = "sscdjson_"
    
    private let userDefaults = UserDefaults.standard
    
    /// Store a MusapKey
    public func storeKey(key: MusapKey, sscd: MusapSscd) throws {
        guard let keyName = key.keyName else {
            print("key name was nil")
            throw MusapException.init(MusapError.missingParam)
        }
        
        // Create the key-specific store name using the prefix and the key name
        let storeName = makeStoreName(keyName: keyName)
        
        // Encode the key to JSON and store it using the store name
        do {
            let keyJson = try JSONEncoder().encode(key)
            userDefaults.set(keyJson, forKey: storeName) // Use storeName to save the key JSON
            print("Key stored with name: \(storeName)")
        } catch {
            print("Could not encode key to JSON: \(error)")
            throw MusapException(MusapError.internalError)
        }
        
        // Insert the key name into the set of known key names and save it
        var newKeyNames = getKeyNames()
        newKeyNames.insert(keyName)
        userDefaults.set(Array(newKeyNames), forKey: MetadataStorage.KEY_NAME_SET)
        
        // It's recommended to save or synchronize changes immediately after making updates
        userDefaults.synchronize() // As of iOS 12, this is no longer needed but can be kept if desired
        print("Updated key names: \(newKeyNames)")
    }
    
    /**
     List available MUSAP keys
     */
    func listKeys() -> [MusapKey] {
        let keyNames = getKeyNames()
        var keyList: [MusapKey] = []

        for keyName in keyNames {
            if let keyData = userDefaults.data(forKey: makeStoreName(keyName: keyName)),
               let key = try? JSONDecoder().decode(MusapKey.self, from: keyData) {
                keyList.append(key)
            } else {
                print("Missing key metadata JSON for key name \(keyName)")
            }
        }

        return keyList
    }
    
    func listKeys(req: KeySearchReq) -> [MusapKey] {
        let keyNames = self.getKeyNames()
        var keyList = [MusapKey]()
        
        for keyName in keyNames {
            let keyJson = self.getKeyJson(keyName: keyName)
            if let jsonData = keyJson.data(using: .utf8) {
                let decoder = JSONDecoder()

                do {
                    let key = try decoder.decode(MusapKey.self, from: jsonData)
                    if (req.keyMatches(key: key)) {
                        keyList.append(key)
                    }
                } catch {
                    print("Error decoding JSON for keyName: \(keyName), error: \(error)")
                }
            }
        }
        return keyList
        
    }
    
    /**
     Remove key metadata from storage
     */
    func removeKey(key: MusapKey) -> Bool {
        guard let keyName = key.keyName else {
            print("Can't remove key. Keyname was nil")
            return false
        }
        
        var newKeyNames = getKeyNames()
        newKeyNames.remove(keyName)

        if let keyJson = try? JSONEncoder().encode(key) {
            userDefaults.set(newKeyNames, forKey: MetadataStorage.KEY_NAME_SET)
            userDefaults.set(keyJson, forKey: makeStoreName(key: key))
            userDefaults.removeObject(forKey: makeStoreName(keyName: keyName))
            return true
        }
        return false
    }
    
    
    /**
     Store metadata of an active MUSAP SSCD
     */
    func addSscd(sscd: MusapSscd) {
        guard let sscdId = sscd.sscdId else {
            print("Cant addSscd: SSCD ID was nil")
            return
        }
        
        // Update SSCD id list with new SSCD ID
        var sscdIds = getSscdIds()
        if !sscdIds.contains(sscdId) {
            sscdIds.insert(sscdId)
        }

        if let sscdJson = try? JSONEncoder().encode(sscd) {
            userDefaults.set(sscdIds, forKey: MetadataStorage.SSCD_ID_SET)
            userDefaults.set(sscdJson, forKey: makeStoreName(sscd: sscd))
        }
    }

    /**
     List available active MUSAP SSCDs
     */
    func listActiveSscds() -> [MusapSscd] {
        let sscdIds = getSscdIds()
        var sscdList: [MusapSscd] = []

        for sscdId in sscdIds {
            if let sscdData = userDefaults.data(forKey: makeStoreName(keyName: sscdId)),
               let sscd = try? JSONDecoder().decode(MusapSscd.self, from: sscdData) {
                sscdList.append(sscd)
            } else {
                print("Missing SSCD metadata JSON for SSCD ID \(sscdId)")
            }
        }

        return sscdList
    }

    
    private func getKeyNames() -> Set<String> {
        // Retrieve the array from UserDefaults and convert it back to a set
        let keyNamesArray = userDefaults.array(forKey: MetadataStorage.KEY_NAME_SET) as? [String] ?? []
        return Set(keyNamesArray)
    }

    private func getSscdIds() -> Set<String> {
        if let sscdIdsArray = userDefaults.stringArray(forKey: MetadataStorage.SSCD_ID_SET) {
            return Set(sscdIdsArray)
        } else {
            return Set()
        }
    }

    private func makeStoreName(key: MusapKey) -> String {
        guard let keyName = key.keyName else {
            fatalError("Cannot create store name for unnamed MUSAP key")
        }
        return MetadataStorage.KEY_JSON_PREFIX + keyName
    }

    private func makeStoreName(sscd: MusapSscd) -> String {
        guard let sscdId = sscd.sscdId else {
            fatalError("Cannot create store name for MUSAP SSCD without an ID")
        }
        return MetadataStorage.SSCD_JSON_PREFIX + sscdId
    }

    private func makeStoreName(keyName: String) -> String {
        return MetadataStorage.KEY_JSON_PREFIX + keyName
    }
    
    private func getKeyJson(keyName: String) -> String {
        return self.makeStoreName(keyName: keyName)
    }
    
    func printAllData() {
        // Print all key names
        let keyNames = getKeyNames()
        print("All Key Names: \(keyNames)")

        // Print all SSCD IDs
        let sscdIds = getSscdIds()
        print("All SSCD IDs: \(sscdIds)")

        // Iterate through each key name and print its JSON
        for keyName in keyNames {
            if let keyData = userDefaults.data(forKey: makeStoreName(keyName: keyName)) {
                print("Data for key '\(keyName)': \(keyData)")
            }
        }

        // Iterate through each SSCD ID and print its JSON
        for sscdId in sscdIds {
            if let sscdData = userDefaults.data(forKey: makeStoreName(keyName: sscdId)) {
                print("Data for SSCD ID '\(sscdId)': \(sscdData)")
            }
        }
    }
    
}
