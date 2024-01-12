//
//  EnrollDataTask.swift
//  MUSAP-demo-app-ios
//
//  Created by Teemu Mänttäri on 11.1.2024.
//

import Foundation

public class EnrollDataTask {
    
    private let link:     MusapLink
    private let fcmToken: String
    
    init(link: MusapLink, fcmToken: String) {
        self.link = link
        self.fcmToken = fcmToken
    }
    
    func enrollData() async throws -> MusapLink {
        do {
            let link: MusapLink = try await self.link.enroll(fcmToken: self.fcmToken)
            MusapStorage().storeLink(link: link)
            return link
        } catch {
            throw MusapError.internalError
        }
    }
    
}
