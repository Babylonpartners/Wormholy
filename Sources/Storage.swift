//
//  Storage.swift
//  Wormholy-SDK-iOS
//
//  Created by Paolo Musolino on 04/02/18.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import Foundation

open class Storage {
    public enum Change {
        case appended([RequestModel])
        case removed(indice: Range<Int>)
        case updated(RequestModel, at: Int)
        case cleared
    }

    public final class Token: Hashable {
        weak var storage: Storage?

        fileprivate init(storage: Storage) {
            self.storage = storage
        }

        public func stopObservation() {
            storage?.transaction { storage?.observers[self] = nil }
        }

        deinit {
            stopObservation()
        }

        public static func == (lhs: Token, rhs: Token) -> Bool {
            return lhs === rhs
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
    }

    public static let shared: Storage = Storage()
    
    open private(set) var requests: [RequestModel] = []
    private var observers: [Token: (Change) -> Void] = [:]
    private let lock = NSLock()

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    func observe(_ action: @escaping (Change) -> Void) -> Token {
        return transaction {
            let token = Token(storage: self)
            observers[token] = action
            action(.appended(requests))
            return token
        }
    }

    func saveRequest(request: RequestModel) {
        transaction {
            let knownRequestIndex = requests.lastIndex(where: { (req) -> Bool in
                return request.id == req.id ? true : false
            })

            if let index = knownRequestIndex {
                requests[index] = request
                notify(.updated(request, at: index))
            } else {
                requests.append(request)
                notify(.appended([request]))
            }

            if requests.count > 100 {
                requests.removeFirst()
                notify(.removed(indice: 0 ..< 1))
            }
        }
    }

    func clearRequests() {
        transaction {
            requests.removeAll()

            for observer in observers.values {
                observer(.cleared)
            }
        }
    }

    @objc private func observeMemoryWarning() {
        clearRequests()
    }

    private func transaction<R>(_ action: () -> R) -> R {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }

    private func notify(_ change: Change) {
        for observer in observers.values {
            observer(change)
        }
    }
}
