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
    var expositionUseCase: ExpositionUseCase! { get set }
    var disposeBag: DisposeBag! { get set }

    func suscribeToExpositionInfo()
}

final class WidgetPresenterDefault: WidgetPresenter {
    var expositionUseCase: ExpositionUseCase!

    internal var disposeBag: DisposeBag! = DisposeBag()

    func suscribeToExpositionInfo() {
        expositionUseCase.getExpositionInfo().subscribe(
            onNext: { exposition in

            }, onError: { error in

        }).disposed(by: disposeBag)
    }
}
