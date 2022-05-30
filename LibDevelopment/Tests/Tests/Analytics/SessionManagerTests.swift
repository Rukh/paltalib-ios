//
//  SessionManagerTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 05.04.2022.
//

import XCTest
import Foundation
import Amplitude
@testable import PaltaLibAnalytics

final class SessionManagerTests: XCTestCase {
    var userDefaults: UserDefaults!
    var notificationCenter: NotificationCenter!

    var sessionManager: SessionManagerImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        userDefaults = UserDefaults()
        notificationCenter = NotificationCenter()

        userDefaults.set(nil, forKey: "paltaBrainSession")

        sessionManager = SessionManagerImpl(userDefaults: userDefaults, notificationCenter: notificationCenter)
    }

    func testRestoreSession() {
        let session = Session(id: 22)
        userDefaults.set(try! JSONEncoder().encode(session), forKey: "paltaBrainSession")

        let newSessionLogged = expectation(description: "New session logged")
        newSessionLogged.isInverted = true

        sessionManager.sessionEventLogger = { _, _ in
            newSessionLogged.fulfill()
        }
        sessionManager.start()

        wait(for: [newSessionLogged], timeout: 0.05)
        XCTAssertEqual(sessionManager.sessionId, session.id)
    }

    func testNoSavedSession() {
        let newSessionLogged = expectation(description: "New session logged")

        sessionManager.sessionEventLogger = { eventName, timestamp in
            XCTAssertEqual(eventName, kAMPSessionStartEvent)
            XCTAssert(abs(Int.currentTimestamp() - timestamp) < 2)
            newSessionLogged.fulfill()
        }
        sessionManager.start()

        wait(for: [newSessionLogged], timeout: 0.05)
    }

    func testExpiredSession() throws {
        var session = Session(id: 22)
        session.lastEventTimestamp = 10
        userDefaults.set(try JSONEncoder().encode(session), forKey: "paltaBrainSession")

        let newSessionLogged = expectation(description: "New session logged")

        sessionManager.sessionEventLogger = { eventName, timestamp in
            XCTAssertEqual(eventName, kAMPSessionStartEvent)
            XCTAssert(abs(Int.currentTimestamp() - timestamp) < 2)
            newSessionLogged.fulfill()
        }
        sessionManager.start()

        wait(for: [newSessionLogged], timeout: 0.05)
    }

    func testAppBecomeActive() {
        let newSessionLogged = expectation(description: "New session logged")

        sessionManager.sessionEventLogger = { eventName, timestamp in
            XCTAssertEqual(eventName, kAMPSessionStartEvent)
            XCTAssert(abs(Int.currentTimestamp() - timestamp) < 2)
            newSessionLogged.fulfill()
        }

        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        wait(for: [newSessionLogged], timeout: 0.05)
    }

    func testCreateNewSession() {
        let lastSessionTimestamp = Int.currentTimestamp() - 1000
        var session = Session(id: 22)
        session.lastEventTimestamp = lastSessionTimestamp
        userDefaults.set(try! JSONEncoder().encode(session), forKey: "paltaBrainSession")
        sessionManager.start()

        let sessionEventLogged = expectation(description: "New session logged")
        sessionEventLogged.expectedFulfillmentCount = 2

        var eventNames: [String] = []
        var eventTimes: [Int] = []

        sessionManager.sessionEventLogger = {
            eventNames.append($0)
            eventTimes.append($1)
            sessionEventLogged.fulfill()
        }

        sessionManager.startNewSession()

        wait(for: [sessionEventLogged], timeout: 0.05)

        XCTAssertEqual(eventNames, [kAMPSessionEndEvent, kAMPSessionStartEvent])
        XCTAssertEqual(eventTimes[0], lastSessionTimestamp)
        XCTAssert(abs(Int.currentTimestamp() - eventTimes[1]) < 4)
    }

    func testRefresh() throws {
        let event = Event.mock(timestamp: 123)

        sessionManager.refreshSession(with: event)

        let session = try userDefaults
            .data(forKey: "paltaBrainSession")
            .map { try JSONDecoder().decode(Session.self, from: $0) }
        XCTAssertEqual(session?.lastEventTimestamp, event.timestamp)
    }
}