//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit
import RxSwift

class CheckOutViewController: VenueViewController {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var venueView: BackgroundView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var timeSC: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    
    var venueRecordUseCase: VenueRecordUseCase!
    
    private var currentVenue: VenueRecord?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccesibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentVenue()
    }
    
    @IBAction func endRegisterTap(_ sender: Any) {
        
        let checkOutDate = getCheckoutFrom(index: timeSC.selectedSegmentIndex)
        
        venueRecordUseCase.checkOut(date: checkOutDate).subscribe(
            onNext: { [weak self] exposition in
                guard let self = self else { return }
                self.router.route(to: .checkOutConfirmation, from: self)
            }, onError: { [weak self] error in
                debugPrint(error)
                self?.showGenericError()
            }).disposed(by: disposeBag)
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    override func finallyCanceled() {
        venueRecordUseCase.cancelCheckIn().subscribe(onNext: {
            super.finallyCanceled()
        }, onError: { [weak self] error in
            debugPrint(error)
            self?.showGenericError()
        }).disposed(by: disposeBag)
    }
    
    @IBAction func timeSCChanged(_ sender: Any) {
        finishButton.isEnabled = true
    }
    
    private func loadCurrentVenue() {
        venueRecordUseCase.getCurrentVenue().subscribe(onNext: { [weak self] venue in
            if let venue = venue {
                self?.load(current: venue)
            }
        }, onError: { [weak self] error in
            debugPrint(error)
            self?.showGenericError()
        }).disposed(by: disposeBag)
    }
    
    private func load(current: VenueRecord) {
        
        self.currentVenue = current
        
        nameLabel.text = current.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.setLocalizedDateFormatFromTemplate("dMMM")
        var day = ""
        if Calendar.current.isDateInToday(current.checkInDate) || Calendar.current.isDateInToday(current.checkInDate) {
            let rdf = DateFormatter()
            rdf.dateStyle = .short
            rdf.doesRelativeDateFormatting = true
            day = rdf.string(from: current.checkInDate).capitalized + ", "
        }
        dateLabel.text = day + dateFormatter.string(from: current.checkInDate).capitalized
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        hourLabel.text = timeFormatter.string(from: current.checkInDate) + " h"
        
    }
    
    private func setupView() {
        
        venueView.image = UIImage(named: "WhiteCard")
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
        finishButton.setTitle("VENUE_RECORD_CHECKOUT_END".localized, for: .normal)
        
        dateView.layer.borderWidth = 1
        dateView.layer.borderColor = UIColor.gray.cgColor
        
        setupSegmentedControl()
        
        if #available(iOS 13.0, *) {
            fixBackgroundSegmentControl(timeSC)
          timeSC.selectedSegmentTintColor = .degradado
        } else {
            timeSC.tintColor = .degradado
        }
        
        timeSC.selectedSegmentIndex = UISegmentedControl.noSegment
        
    }
    
    private func setupSegmentedControl() {
        timeSC.layer.borderWidth = 1
        timeSC.layer.borderColor = UIColor.deepLilac.cgColor
        
        var segAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold)]
        timeSC.setTitleTextAttributes(segAttributes, for: .selected)
        
        segAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold)]
        timeSC.setTitleTextAttributes(segAttributes, for: .normal)
        
        timeSC.setImage(imageWith(name:"VENUE_RECORD_CHECKOUT_LEAVE_NOW".localizedAttributed.string), forSegmentAt: 0)
    }
    
    private func setupAccesibility() {
        finishButton.accessibilityHint = "VENUE_RECORD_CHECKOUT_END".localized
        finishButton.accessibilityHint = "ACC_HINT".localized
        finishButton.isAccessibilityElement = true
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityHint = "ACC_BUTTON_ALERT_CANCEL".localized
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
            let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            context!.setFillColor(color.cgColor);
            context!.fill(rect);
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image!
    }
    
    private func fixBackgroundSegmentControl( _ segmentControl: UISegmentedControl){
        if #available(iOS 13.0, *) {
            //just to be sure it is full loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for i in 0...(segmentControl.numberOfSegments-1)  {
                    let backgroundSegmentView = segmentControl.subviews[i]
                    //it is not enogh changing the background color. It has some kind of shadow layer
                    backgroundSegmentView.isHidden = true
                }
            }
        }
    }
    
    private func imageWith(name: String?) -> UIImage? {
         let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
         let nameLabel = UILabel(frame: frame)
         nameLabel.textAlignment = .center
         nameLabel.backgroundColor = .clear
         nameLabel.textColor = .black
         nameLabel.numberOfLines = 0
         nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
         nameLabel.text = name
         UIGraphicsBeginImageContext(frame.size)
          if let currentContext = UIGraphicsGetCurrentContext() {
             nameLabel.layer.render(in: currentContext)
             let nameImage = UIGraphicsGetImageFromCurrentImageContext()
             return nameImage
          }
          return nil
    }
    
    private func getCheckoutFrom(index: Int) -> Date {
        guard let checkInDate = currentVenue?.checkInDate else {
            return Date()
        }
        if index == 0 {
            return Date()
        }
        
        if index == 1 {
            return checkInDate.addingTimeInterval(30 * 60)
        }
        
        if index > 1 && index <= 3{
            return checkInDate.addingTimeInterval( Double((index - 1)) * 60.0 * 60.0 )
        }
        
        if index > 3 {
            return checkInDate.addingTimeInterval( Double((index)) * 60.0 * 60.0 )
        }
        
        return Date()
    }
    
}
