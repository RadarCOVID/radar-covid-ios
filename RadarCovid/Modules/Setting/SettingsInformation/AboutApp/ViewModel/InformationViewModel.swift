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
import UIKit
import RxSwift
import ExposureNotification
import DP3TSDK

class InformationViewModel {
    
    private var radarStatusUseCase: RadarStatusUseCase!
    private var expositionUseCase: ExpositionUseCase!
    private var exposureRecordRepository: ExposureRecordRepository!
    
    var appInformation = BehaviorSubject<AppInformation>(value: AppInformation())
    var strBuildShareMessage: String?
    
    private var disposeBag = DisposeBag()
    
    init(radarStatusUseCase: RadarStatusUseCase,
         expositionUseCase: ExpositionUseCase,
         exposureRecordRepository: ExposureRecordRepository) {
        
        self.radarStatusUseCase = radarStatusUseCase
        self.expositionUseCase = expositionUseCase
        self.exposureRecordRepository = exposureRecordRepository
        
        self.appInformation
            .subscribe(onNext: { [weak self] (value) in
                self?.strBuildShareMessage = self?.buildShareMessage(appInformation: value)
            }).disposed(by: disposeBag)
        
    }
    
    func getAppInformation() {
        
        let radarStatus = radarStatusUseCase?.isTracingActive() ?? false
        let bluetoothStatus:Bool = (UIApplication.shared.delegate as? AppDelegate)?.bluethoothUseCase?.getSatus() ?? false
        let aInformation = AppInformation.init( radarStatus: radarStatus,
                                                notificationStatus: false,
                                                bluetooth: bluetoothStatus,
                                                lastSync: expositionUseCase?.lastSync)
        appInformation.onNext(aInformation)
        
        //Get last exposition
        expositionUseCase.getExpositionInfo()
            .subscribe(
                onNext: { [weak self] exposition in
                    guard let weakSelf = self else {
                        return
                    }
                    do {
                        var aInformation = try weakSelf.appInformation.value()
                        if let lastCheck = exposition.contact.lastCheck {
                            aInformation.lastSync = lastCheck
                            aInformation.onSync = true
                            weakSelf.appInformation.onNext(aInformation)
                        }
                        weakSelf.getStatusNotification()
                        weakSelf.getStatusRadar()
                    } catch _ { }
                    
                }).disposed(by: disposeBag)
    }
    
    func formatDate(date: Date) -> String {
        guard let days = date.getDays(),
              let year = date.getYears() else {
            return ""
        }
        let strDay = "\(days)"
        let monthName = date.getMonthName()
        let strYear = "\(year)"
        let hourName = date.getHourFormatter()
        
        var stringDate:String = "INFO_DATE_FORMAT".localized
        stringDate = stringDate.localized.replacingOccurrences(of: "$D", with: strDay)
        stringDate = stringDate.localized.replacingOccurrences(of: "$M", with: monthName)
        stringDate = stringDate.localized.replacingOccurrences(of: "$Y", with: strYear)
        stringDate = stringDate.localized.replacingOccurrences(of: "$H", with: hourName)
        
        return stringDate
    }
    
    func getExposureRecordDates() -> [Date?] {
        exposureRecordRepository.getExposureRecords().map { $0.since }
    }
    
    private func getStatusNotification() {
        let status = ENManager.authorizationStatus
        
        guard var information = try? self.appInformation.value() else {
            return
        }
        
        switch DP3TTracing.status.trackingState {
        case .active:
            if status == ENAuthorizationStatus.authorized {
                information.notificationStatus = true
            }
        default:
            information.notificationStatus = false
        }
        
        self.appInformation.onNext(information)
    }
    
    private func getStatusRadar() {
        let radarStatus = radarStatusUseCase?.isTracingActive() ?? false
        radarStatusUseCase.changeTracingStatus(active: radarStatus).subscribe(
            onNext: { [weak self] status in
                guard var information = try? self?.appInformation.value() else {
                    return
                }
                
                switch status {
                case .active: information.radarStatus = true
                default: information.radarStatus = false
                }
                self?.appInformation.onNext(information)
            }, onError: {  [weak self] _ in
                guard var information = try? self?.appInformation.value() else {
                    return
                }
                information.radarStatus = false
                self?.appInformation.onNext(information)
            }).disposed(by: disposeBag)
    }
    
    private func buildShareMessage(appInformation: AppInformation) -> String {
        var strLastSync:String = ""
        if let lastSync = appInformation.lastSync {
            strLastSync = formatDate(date: lastSync)
        }
        
        let message = "\("INFO_SHARE_MESSAGE".localized) \n\n \("INFO_APP_VERSION".localized): \(appInformation.version); \("INFO_RADAR_STATUS".localized):  \(appInformation.radarStatus ? "ACTIVE".localized : "INACTIVE".localized); \("INFO_NOTIFICATION_STATUS".localized):  \(appInformation.notificationStatus ? "ACTIVE".localized : "INACTIVE".localized); \("INFO_BLUETOOTH_STATUS".localized):  \(appInformation.bluetooth ? "ACTIVE".localized : "INACTIVE".localized); \("INFO_LAST_SYNC".localized): \(strLastSync); \("INFO_SO_VERSION".localized): \(appInformation.so); \("INFO_DEVICE_MODEL".localized): \(appInformation.model);"
        return message
    }
}
