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
import BackgroundTasks
import RxSwift
import Logging

protocol BackgroundTask {
    
    var timeBetween : TimeInterval { get }
    var taskKey: String { get }
    
    func run() -> Observable<Any?>
    
}

@available(iOS 13.0, *)
class BackgroundTaskScheduler {
    
    private let logger = Logger(label: "BackgroundTaskScheduler")
    
    private let disposeBag = DisposeBag()
    
    private let task : BackgroundTask
    
    init(task: BackgroundTask) {
        self.task = task
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: task.taskKey, using: nil) { [weak self] bgTask in
            guard let self  = self else {
                return
            }
            bgTask.expirationHandler = { [weak self] in
                self?.logger.error("\(task.taskKey) Expired")
            }
            task.run().subscribe(onNext: { data in
                self.logger.debug("\(task.taskKey) task result \(String(describing: data))")
            }, onError: { error in
                self.logger.error("Error running \(task.taskKey) task: \(error.localizedDescription)")
                bgTask.setTaskCompleted(success: true)
                self.schedule()
            }, onCompleted: {
                self.logger.debug("\(task.taskKey) task")
                bgTask.setTaskCompleted(success: true)
                self.schedule()
            }).disposed(by: self.disposeBag)
        }
    }
    
    func schedule() {
        
        let taskRequest = BGAppRefreshTaskRequest(identifier: task.taskKey)
        taskRequest.earliestBeginDate = Date(timeIntervalSinceNow: task.timeBetween)
        
                
        logger.debug("Scheduling Task: \(task.taskKey), earliestBeginDate: \(String(describing: taskRequest.earliestBeginDate))")
        
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            logger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
}


class DummyTask : BackgroundTask {
    
    private let logger = Logger(label: "DummyTask")
    
    var timeBetween: TimeInterval {
        get {
            return 2*60
        }
    }
    
    var taskKey: String = "es.gob.radarcovid.dummy"
    
    func run() -> Observable<Any?> {
        .deferred {
            self.logger.debug("Running \(self.taskKey)....")
            return .just("Success!!!")
        }
    }
    
    
}
