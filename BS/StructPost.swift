//
//  StructPost.swift
//  BS
//
//  Created by daniel martinez gonzalez on 19/8/16.
//  Copyright © 2016 daniel martinez gonzalez. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class Post: Object
{
    dynamic var id = ""
    dynamic var author = ""
    dynamic var title = ""
    dynamic var created = ""
    dynamic var score = 0
    dynamic var comments = 0
    dynamic var thumbnail = ""
    dynamic var url = ""
    
    override static func primaryKey() -> String?
    {
        return "id"
    }
}
