//
//  WormholyTests.swift
//  Wormholy
//
//  Created by Paolo Musolino on {TODAY}.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import Foundation
import XCTest
@testable import Wormholy

class WormholyTests: XCTestCase {
    func test_curl_get_unauthenticated() {
        let generated = RequestModelBeautifier.curlExport(request: RequestModel.fixture(endpoint: .regions))

        let expected = "curl -H 'accept: application/json' -H 'accept-language: en-US' -H 'content-type: application/json' -H 'host: preprod.somecompany.com' -H 'x-app-name: somecompany' -H 'x-app-version: 4.7.0' -H 'x-platform: ios' -H 'x-platform-version: 12.4' -X GET --compressed 'https://preprod.somecompany.com/api/v1/regions'"

        XCTAssertTrue(generated == expected)
    }

    func test_curl_get_authenticated() {
        let generated = RequestModelBeautifier.curlExport(
            request: RequestModel.fixture(endpoint: .regions, token: WormholyTests.authenticatedToken)
        )

        let expected = "curl -H 'accept: application/json' -H 'accept-language: en-US' -H 'authorization: Bearer \(WormholyTests.authenticatedToken)' -H 'content-type: application/json' -H 'host: preprod.somecompany.com' -H 'x-app-name: somecompany' -H 'x-app-version: 4.7.0' -H 'x-platform: ios' -H 'x-platform-version: 12.4' -X GET --compressed 'https://preprod.somecompany.com/api/v1/regions'"

        XCTAssertTrue(generated == expected)
    }

    func test_curl_post() {
        let generated = RequestModelBeautifier.curlExport(
            request: RequestModel.fixture(
                endpoint: .createAccount,
                method: .post,
                httpBody: try? JSONSerialization.data(withJSONObject: WormholyTests.payload, options: [])
            )
        )

        let expected = "curl -H 'accept: application/json' -H 'accept-language: en-US' -H 'content-type: application/json' -H 'host: dev.somecompany.com' -H 'x-app-name: somecompany' -H 'x-app-version: 4.7.0' -H 'x-platform: ios' -H 'x-platform-version: 12.4' --data-binary '{\"name\":\"Erich Zann\"}' -X POST --compressed 'https://dev.somecompany.com/api/v2/patients'"

        XCTAssertTrue(generated == expected)
    }

    func test_curl_put() {
        let generated = RequestModelBeautifier.curlExport(
            request: RequestModel.fixture(
                endpoint: .patientDetails,
                method: .put,
                token: WormholyTests.authenticatedToken,
                httpBody: try? JSONSerialization.data(withJSONObject: WormholyTests.payload, options: [])
            )
        )

        let expected = "curl -H 'accept: application/json' -H 'accept-language: en-US' -H 'authorization: Bearer \(WormholyTests.authenticatedToken)' -H 'content-type: application/json' -H 'host: dev.somecompany.com' -H 'x-app-name: somecompany' -H 'x-app-version: 4.7.0' -H 'x-platform: ios' -H 'x-platform-version: 12.4' --data-binary '{\"name\":\"Erich Zann\"}' -X PUT --compressed 'https://dev.somecompany.com/api/v1/patients/9541561'"

        XCTAssertTrue(generated == expected)
    }

    func test_curl_patch() {
        let generated = RequestModelBeautifier.curlExport(
            request: RequestModel.fixture(
                endpoint: .patientDetails,
                method: .patch,
                token: WormholyTests.authenticatedToken,
                httpBody: try? JSONSerialization.data(withJSONObject: WormholyTests.payload, options: [])
            )
        )

        let expected = "curl -H 'accept: application/json' -H 'accept-language: en-US' -H 'authorization: Bearer \(WormholyTests.authenticatedToken)' -H 'content-type: application/json' -H 'host: dev.somecompany.com' -H 'x-app-name: somecompany' -H 'x-app-version: 4.7.0' -H 'x-platform: ios' -H 'x-platform-version: 12.4' --data-binary '{\"name\":\"Erich Zann\"}' -X PATCH --compressed 'https://dev.somecompany.com/api/v1/patients/9541561'"

        XCTAssertTrue(generated == expected)
    }

    func test_curl_delete() {
        let generated = RequestModelBeautifier.curlExport(
            request: RequestModel.fixture(endpoint: .regions, method: .delete, token: WormholyTests.authenticatedToken)
        )

        let expected = "curl -H 'accept: application/json' -H 'accept-language: en-US' -H 'authorization: Bearer \(WormholyTests.authenticatedToken)' -H 'content-type: application/json' -H 'host: preprod.somecompany.com' -H 'x-app-name: somecompany' -H 'x-app-version: 4.7.0' -H 'x-platform: ios' -H 'x-platform-version: 12.4' -X DELETE --compressed 'https://preprod.somecompany.com/api/v1/regions'"

        XCTAssertTrue(generated == expected)
    }
}

extension WormholyTests {
    fileprivate enum HTTPMethod: String {
        case get
        case post
        case put
        case patch
        case delete

        var value: String {
            return self.rawValue.uppercased()
        }
    }

    fileprivate enum Endpoints: String {
        case regions = "https://preprod.somecompany.com/api/v1/regions"
        case patientDetails = "https://dev.somecompany.com/api/v1/patients/9541561"
        case createAccount = "https://dev.somecompany.com/api/v2/patients"

        var url: URL {
            return URL(string: rawValue)!
        }
    }

    fileprivate static let headers: [String: String] = [
        "content-type": "application/json",
        "accept": "application/json",
        "x-app-name": "somecompany",
        "x-platform-version": "12.4",
        "accept-language": "en-US",
        "x-app-version": "4.7.0",
        "x-platform": "ios"
    ]

    fileprivate static let authenticatedToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ik1FWkNOamswTmtVMU1UUkZNamRGTlVKRU9VVkNSRVl5TURrMk4wVkJNekJGTlRaQ1JURkVSUSJ9.eyJodHRwczovL2JhYnlsb25oZWFsdGguY29tL3VzZXIiOiI2YThiMDRmNy0wODY5LTRkNDYtOGUyNC1kYTQ5YzFiMjhmODAiLCJodHRwczovL2JhYnlsb25oZWFsdGguY29tL3VzZXIzMiI6NTcwODA0MywiaHR0cHM6Ly9iYWJ5bG9uaGVhbHRoLmNvbS9hbGxvd2VkLXJlZ2lvbnMiOiJwcmVwcm9kLXVrIiwiaHR0cHM6Ly9iYWJ5bG9uaGVhbHRoLmNvbS9ydWJ5LXRva2VuIjoiZjU3ZDNmYmI3NjU1NjI2YTg4ZjMxOWUzOTg5ZjUzZDgiLCJpc3MiOiJodHRwczovL2JhYnlsb24tcHJlcHJvZC1zZy5ldS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8c3RhdGljLXVzZXItaWQiLCJhdWQiOiJodHRwczovL2JhYnlsb25oZWFsdGguY29tIiwiaWF0IjoxNTY5MTA4NjEwLCJleHAiOjE1NjkxMTA0MTAsImF6cCI6IlY0cmdHWFQ4VGFWT1R5cXczWTZ4ZllMWGpNT0x6QTdCIiwic2NvcGUiOiJpbnRlcm5hbCBvZmZsaW5lX2FjY2VzcyIsImd0eSI6InBhc3N3b3JkIn"

    fileprivate static let payload = ["name": "Erich Zann"]
}

extension RequestModel {
    fileprivate convenience init(
        endpoint: WormholyTests.Endpoints,
        method: String,
        headers: [String: String]? = nil,
        token: String? = nil,
        httpBody: Data? = nil
    ) {
        let request = NSMutableURLRequest(url: endpoint.url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method

        if let httpBody = httpBody {
            request.httpBody = httpBody
        }

        if let host = endpoint.url.host {
            request.addValue(host, forHTTPHeaderField: "Host")
        }

        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        }

        self.init(request: request)
    }

    fileprivate static func fixture(
        endpoint: WormholyTests.Endpoints,
        method: WormholyTests.HTTPMethod = .get,
        headers: [String: String] = WormholyTests.headers,
        token: String? = nil,
        httpBody: Data? = nil
    ) -> RequestModel {
        return RequestModel(
            endpoint: endpoint,
            method: method.value,
            headers: headers,
            token: token,
            httpBody: httpBody
        )
    }
}
