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

enum QuestionType {
    case rate
    case singleSelect
    case multiSelect
    case text
}

class Question {
    public var _id: Int?
    public var type: QuestionType?
    public var question: String?
    public var options: [QuestionOption]?
    public var minValue: Int?
    public var maxValue: Int?
    public var mandatory: Bool?
    public var position: Int?
    public var childPosition: Int?
    public var parent: Int?
    public var parentOption: Int?
    public var valuesSelected: [Any?]?

    init() {

    }

    init(type: QuestionType, question: String, minValue: Int?, maxValue: Int?) {
        self.type = type
        self.minValue = minValue
        self.maxValue = maxValue
        self.question = question
    }

    func getSelectedOption() -> QuestionOption? {
        for option in options ?? [] where option.selected ?? false {
            return option

        }
        return nil
    }

    func isChild() -> Bool {
        parent != nil
    }

    func hasResponse() -> Bool {
        if !(valuesSelected ?? []).isEmpty {
            return true
        }

        for option in options ?? [] where option.selected ?? false {
            return true
        }
        return false
    }
}
