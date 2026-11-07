//
//  NoteModel.swift
//  BeeWise
//
//  Created by Mac on 04/11/26.
//

import Foundation
import SwiftData

@Model
final class NoteModel{
    var title: String
    var body: String
    var isDone: Bool
    var createdAt: Date
    
    init(title: String = "", body: String = "")
    {
        self.title = title
        self.body = body
        self.isDone = false
        self.createdAt = .now
    }
}
