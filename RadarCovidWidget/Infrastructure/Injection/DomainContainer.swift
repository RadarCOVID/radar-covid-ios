//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Swinject

class DomainContainer {
    @discardableResult
    init(container: Container) { prepareInjections(container: container) }

    internal func prepareInjections(container: Container) {
        container.register(SetupUseCase.self) { resolver in
            SetupUseCase(preferencesRepository: resolver.resolve(PreferencesRepository.self)!,
                         notificationHandler: resolver.resolve(NotificationHandler.self)!,
                         expositionCheckUseCase: resolver.resolve(ExpositionCheckUseCase.self)!)
        }.inObjectScope(.container)

        container.register(ExpositionCheckUseCase.self) { resolver in
            ExpositionCheckUseCase(
                expositionInfoRepository: resolver.resolve(ExpositionInfoRepository.self)!,
                settingsRepository: resolver.resolve(SettingsRepository.self)!,
                resetDataUseCase: resolver.resolve(ResetDataUseCase.self)!)
        }.inObjectScope(.container)

        container.register(ExpositionUseCase.self) { resolver in
            ExpositionUseCase(notificationHandler: resolver.resolve(NotificationHandler.self)!,
                              expositionInfoRepository: resolver.resolve(ExpositionInfoRepository.self)!)
        }.inObjectScope(.container)

        container.register(ResetDataUseCase.self) { resolver in
            ResetDataUseCaseImpl(expositionInfoRepository: resolver.resolve(ExpositionInfoRepository.self)!)
        }.initCompleted { resolver, useCase in
            (useCase as! ResetDataUseCaseImpl).setupUseCase = resolver.resolve(SetupUseCase.self)!
        }.inObjectScope(.container)
    }
}
