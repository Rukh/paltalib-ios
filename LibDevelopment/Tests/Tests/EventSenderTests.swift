//
//  EventSenderTests.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import XCTest
@testable import PaltaLibCore
@testable import PaltaLibAnalytics

final class EventSenderTests: XCTestCase {
    let events: [Event] = [.mock()]

    var httpClientMock: HTTPClientMock!
    var eventSender: EventSenderImpl!

    override func setUpWithError() throws {
        try super.setUpWithError()

        httpClientMock = HTTPClientMock()
        eventSender = EventSenderImpl(httpClient: httpClientMock)
        eventSender.apiToken = "mockToken"
    }
    
    func testSuccessfulRequest() {
        httpClientMock.result = .success(EmptyResponse())
        let successCalled = expectation(description: "Success called")

        eventSender.sendEvents(events) { result in
            switch result {
            case .success:
                successCalled.fulfill()
            case .failure:
                break
            }
        }

        wait(for: [successCalled], timeout: 0.01)
        XCTAssertEqual(
            httpClientMock.request as? AnalyticsHTTPRequest,
            AnalyticsHTTPRequest.sendEvents(SendEventsPayload(apiKey: "mockToken", events: events))
        )
    }

    func testNoInternet() {
        httpClientMock.result = .failure(URLError(.notConnectedToInternet))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .noInternet)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.01)
    }

    func testTimeout() {
        httpClientMock.result = .failure(URLError(.timedOut))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .timeout)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.01)
    }

    func test400() {
        httpClientMock.result = .failure(NSError(domain: URLError.errorDomain, code: 422, userInfo: nil))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .badRequest)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.01)
    }

    func test500() {
        httpClientMock.result = .failure(NSError(domain: URLError.errorDomain, code: 501, userInfo: nil))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .serverError)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.01)
    }

    func testUnknownError() {
        httpClientMock.result = .failure(NSError(domain: "Some domain", code: 1001, userInfo: nil))

        let failCalled = expectation(description: "Fail called")

        eventSender.sendEvents(events) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTAssertEqual(error, .unknown)
                failCalled.fulfill()
            }
        }

        wait(for: [failCalled], timeout: 0.01)
    }
}