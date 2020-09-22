//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation
import Swinject

final class Injector {
    static let shared = Injector()
    internal var currentContainer = Container()

    private let defaultContainer = Container()

    init() {
        InfrastructureContainer(container: currentContainer)
        DataContainer(container: currentContainer)
        DomainContainer(container: currentContainer)
        PresentationContainer(container: currentContainer)
    }

    func use(container: Container) {
        currentContainer = container
    }

    func resetContainer() {
        currentContainer = defaultContainer
    }
}

prefix operator <~
prefix func <~<Injection>(right: Injection.Type) -> Injection {
    if let registeredInjection = Injector.shared.currentContainer.resolve(Injection.self) {
        return registeredInjection
    } else {
        fatalError("Cannot resolve \(Injection.self)")
    }
}

