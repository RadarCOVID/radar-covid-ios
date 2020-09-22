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
import RxSwift

protocol WidgetPresenter {
    var expositionUseCase: ExpositionUseCase! { get }
    var expositionInfo: ExpositionInfo! { get }
    var expositionError: Error? { get }

    func suscribeToExpositionInfo()
    func updateExpositionInfo()
}

final class WidgetPresenterDefault: WidgetPresenter {
    private(set) var expositionUseCase: ExpositionUseCase! = <~ExpositionUseCase.self
    private(set) var expositionInfo: ExpositionInfo! = ExpositionInfo(level: .unknown)
    private(set) var expositionError: Error?
    private var disposeBag: DisposeBag! = DisposeBag()

    func suscribeToExpositionInfo() {
        expositionUseCase.getExpositionInfo().subscribe(
            onNext: { exposition in
                self.expositionInfo = exposition
            }, onError: { error in
                self.expositionError = error
        }).disposed(by: disposeBag)
    }

    func updateExpositionInfo() {
        expositionUseCase.updateExpositionInfo()
    }
}
