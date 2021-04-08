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

class VenueListViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    var router: AppRouter!
    var viewModel: VenueListViewModel!
    
    private var venueMap: [TimeInterval: [VenueRecord]] = [:]
    
    private var sortedKeys: [TimeInterval] = []

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var showHiddenSwitch: UISwitch!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var hiddenCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBinding()
        setupAccesibility()
        self.showHiddenSwitch.onTintColor = UIColor.degradado
    }
    
    private func setupBinding() {
        viewModel.error.subscribe { [weak self] error in
            self?.showAlertOk(title: "ALERT_GENERIC_ERROR_TITLE".localized,
                              message: "ALERT_GENERIC_ERROR_CONTENT".localized,
                              buttonTitle: "ALERT_ACCEPT_BUTTON".localized)
        }.disposed(by: disposeBag)
        
        viewModel.venueMap.subscribe{ [weak self] venueMap in
            self?.venueMap = venueMap.element ?? [:] as! [TimeInterval : [VenueRecord]]
            self?.sortedKeys = self?.sortedKeys(self?.venueMap) ?? []
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        showHiddenSwitch.rx.isOn.bind(to: viewModel.showHidden).disposed(by: disposeBag)
        
        viewModel.showHidden.subscribe { [weak self] show in
            if let show = show.element {
                self?.switchLabel.text = show ? "VENUE_DIARY_VISIBLE".localized : "VENUE_DIARY_HIDDEN".localized
                self?.showHiddenSwitch.accessibilityHint = show ? "ACC_HIDE_SWITCH_ON_HINT".localized : "ACC_HIDE_SWITCH_ON_HINT".localized
            }
        }.disposed(by: disposeBag)
        
        viewModel.numHidden.subscribe { [weak self] count in
            self?.hiddenCountLabel.text = "VENUE_DIARY_HIDDEN_PLACES".localizedAttributed(withParams: [String(count)]).string
        }.disposed(by: disposeBag)
        
        viewModel.showEmpty.subscribe { [weak self] showEmpty in
            if let showEmpty = showEmpty.element {
                self?.emptyView.isHidden = showEmpty
                self?.listView.isHidden = !showEmpty
            }
        }.disposed(by: disposeBag)
        
    }
    
    private func setupAccesibility() {
        showHiddenSwitch.isAccessibilityElement = true
    }

    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "VenueViewCell", bundle: nil), forCellWithReuseIdentifier: "CELL")
        collectionView.register(UINib.init(nibName: "DateHeader", bundle: nil),
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HEADER")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchVenues()
    }

    @IBAction func onBack(_ sender: Any) {
        router.pop(from: self, animated: true)
    }
    
}

extension VenueListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width - 32, height: 128.0)
    }
}

extension VenueListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Array(venueMap.values)[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! VenueViewCell
        let section = sortedKeys[indexPath.section]
        cell.venue = venueMap[section]?[indexPath.item]
        cell.venueHideDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HEADER", for: indexPath) as! DateHeader
        let section = sortedKeys[indexPath.section]
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
        header.date = dateFormatter.string(from: Date(timeIntervalSince1970: section)).capitalized
        
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        venueMap.count
    }
    
    private func sortedKeys(_ map: [TimeInterval:[VenueRecord]]?) -> [TimeInterval]? {
        map?.keys.sorted(by: > )
    }
    
}

extension VenueListViewController: VenueHideDelegate {
    
    func hide(venue: VenueRecord) {
        viewModel.toggleHide(venue: venue)
    }
    
}
