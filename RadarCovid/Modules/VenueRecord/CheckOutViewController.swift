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
    
    var venueRecordUseCase: VenueRecordUseCase!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @IBAction func endRegisterTap(_ sender: Any) {
        
        venueRecordUseCase.checkOut(date: Date()).subscribe(
            onNext: { [weak self] exposition in
                guard let self = self else { return }
                self.router.route(to: .checkOutConfirmation, from: self)
            }, onError: { [weak self] error in
                debugPrint(error)
                self?.showAlertOk(
                    title: "",
                    message: "ERROR REGISTER",
                    buttonTitle: "ALERT_ACCEPT_BUTTON".localized)
                
            }).disposed(by: disposeBag)
    }
    
    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
    override func finallyCanceled() {
        venueRecordUseCase.cancelCheckIn()
        super.finallyCanceled()
    }
    
    private func setupView() {
        
        venueView.image = UIImage(named: "WhiteCard")
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        
        dateView.layer.borderWidth = 1
        dateView.layer.borderColor = UIColor.gray.cgColor
        
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
        
        timeSC.setImage(imageWith(name:"SALGO\nAHORA"), forSegmentAt: 0)

        
        if #available(iOS 13.0, *) {
            fixBackgroundSegmentControl(timeSC)
          timeSC.selectedSegmentTintColor = .degradado
        } else {
            timeSC.tintColor = .degradado
        }
        

//        timeSC.setDividerImage(imageWithColor(color: .degradado), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

//        timeSC.setBackgroundImage(imageWithColor(color: .white), for: .normal, barMetrics: .default)
//        timeSC.setBackgroundImage(imageWithColor(color: .degradado), for: .selected, barMetrics: .default)
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
    
}
