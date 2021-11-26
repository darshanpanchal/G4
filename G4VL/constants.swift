//
//  constants.swift
//  G4VL
//
//  Created by Foamy iMac7 on 10/07/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import Foundation


struct Defaults {
    static let compression : CGFloat = 0.5
}

struct Api {
    
    //Params
    static let USER = "user"
    static let MESSAGE = "message"
    static let COMPANIES = "companies"
    static let FIELDS = "fields"
    static let ROWS = "rows"
    static let OPTIONS = "options"
    static let IDENTIFIER = "identifier"
    static let STATE = "state"
    static let TITLE = "title"
    static let UNITS = "units"
    static let DESCRIPTION = "description"
    static let MAX = "max"
    static let MIN = "min"
    static let VALUE = "value"
    static let NAME = "name"
    static let SELECTED = "selected"
    static let PARTS = "parts"
    static let PERSPECTIVES = "parts"
    static let DAMAGES = "damages"
    static let APPRAISAL = "appraisal"
    static let DRIVER_ID = "driver_id"
    static let STEP = "step"
    
}

struct Colours {
    static let MASK_COLOUR = UIColor(red: 1.0, green: 102/255.0, blue: 102/255.0, alpha: 0.7)
    static let GREEN_MASK_COLOUR = UIColor(red: 0/255.0, green: 153/255.0, blue: 0/255.0, alpha: 0.7)//     rgb(152,251,152)
}

struct PusherConst {
    static let API_KEY = "53d96a2d3e6ef5a56428"
    static let APP_ID = "417487"
    static let SECRET = "20e0ea4d2eb07ce6e562"
    static let CLUSTER = "eu"
}


struct Preferences {
    static let SECRET = "fgzjXl" + UIDevice.current.identifierForVendor!.uuidString
    static let DRIVER = "driver"
    static let TOUCH_ID_ENABLED = "touch_id_enabled"
    static let TOUCH_ID_REQUESTED = "touch_id_requested"
    static let USERNAME = "username"
    static let PASSWORD = "password"
    static let LAST_OPENED = "LAST_OPENED"
    
    static let VIDEO_QUEUE = "VIDEO_QUEUE"
    static let ERROR_QUEUE = "ERROR_QUEUE"
    static let JOB_STATUS_QUEUE = "JOB_STATUS_QUEUE"
}

struct Notification {
    static let REFRESH_VEHICAL_DETAILS = "REFRESH_VEHICAL_DETAILS"
    static let REFRESH_VEHICAL_PARTS = "REFRESH_VEHICAL_PARTS"
    static let REFRESH_JOBS = "REFRESH_JOBS"
    static let REFRESH_PERMISSIONS = "REFRESH_PERMISSIONS"
    static let LOG_USER_IN = "LOG_USER_IN"
    static let LOG_OUT = "LOG_OUT"
}


struct CarParts {
    static let WINDSCREEN = "windscreen"
    static let HOOD = "hood"
    static let ROOF = "roof"
    static let FRONT_BUMPER = "front-bumper"
    static let INSIDE = "inside"
    static let REAR_WINDOW = "rear-window"
    static let BACK_LIGHT_PASSENGER = "back-light-passenger"
    static let DRIVER_HEAD_LIGHT = "driver-head-light"
    static let PASSENGER_HEAD_LIGHT = "passenger-head-light"
    static let FRONT_DRIVER_ALLOY = "front-driver-alloy"
    static let FRONT_PASSENGER_ALLOY = "front-passenger-alloy"
    static let PASSENGER_WING_MIRROR = "passenger-wing-mirror"
    static let DRIVER_WING_MIRROR = "driver-wing-mirror"
    static let BACK_BUMPER = "back-bumper"
    static let BACK_LIGHT_DRIVER = "back-light-driver"
    static let BOOT = "boot"
    static let BACK_DRIVER_ALLOY = "back-driver-alloy"
    static let BACK_PASSENGER_ALLOY = "back-passenger-alloy"
    static let BACK_DRIVER_DOOR = "back-driver-door"
    static let BACK_DRIVER_WINDOW = "back-driver-window"
    static let BACK_PASSENGER_DOOR = "back-passenger-door"
    static let BACK_PASSENGER_WINDOW = "back-passenger-window"
    static let FRONT_DRIVER_WINDOW = "front-driver-window"
    static let FRONT_DRIVER_DOOR = "front-driver-door"
    static let FRONT_PASSENGER_PANEL = "front-passenger-panel"
    static let FRONT_DRIVER_PANEL = "front-driver-panel"
    static let BACK_PASSENGER_PANEL = "back-passenger-panel"
    static let BACK_DRIVER_PANEL = "back-driver-panel"
    static let FRONT_PASSENGER_WINDOW = "front-passenger-window"
    static let FRONT_PASSENGER_DOOR = "front-passenger-door"
    static let BACK_DRIVER_TYRE = "back-driver-tyre"
    static let BACK_PASSENGER_TYRE = "back-passenger-tyre"
    static let FRONT_DRIVER_TYRE = "front-driver-tyre"
    static let FRONT_PASSENGER_TYRE = "front-passenger-tyre"
}


struct VanParts {
    static let PASSENGER_FRONT_PANEL = "passenger-side-front-panel"
    static let DRIVER_FRONT_PANEL = "driver-side-front-panel"
    static let FRONT_BUMPER = "front-bumper"
    static let WINDSCREEN = "windscreen"
    static let BACK_BUMPER = "back-bumper"
    static let BACK_DOOR = "back-door"
    static let BACK_DRIVER_TYRE = "back-driver-tyre"
    static let BACK_PASSENGER_TYRE = "back-passenger-tyre"
    static let BACK_LIGHT_PASSENGER = "back-light-passenger"
    static let BACK_LIGHT_DRIVER = "back-light-driver"
    static let PASSENGER_WING_MIRROR = "passenger-wing-mirror"
    static let DRIVER_WING_MIRROR = "driver-wing-mirror"
    static let DRIVER_HEAD_LIGHT = "driver-head-light"
    static let PASSENGER_HEAD_LIGHT = "passenger-head-light"
    static let FRONT_DRIVER_TYRE = "front-driver-tyre"
    static let FRONT_PASSENGER_TYRE = "front-passenger-tyre"
    static let INSIDE = "inside"
    static let BACK_DRIVER_ALLOY = "back-driver-alloy"
    static let BACK_PASSENGER_ALLOY  = "back-passenger-alloy"
    static let FRONT_DRIVER_ALLOY  = "front-driver-alloy"
    static let FRONT_PASSENGER_ALLOY  = "front-passenger-alloy"
    static let PASSENGERS_DOOR = "passenger-door"
    static let DRIVER_DOOR = "driver-door"
    static let FRONT_PASSENGER_WINDOW = "passenger-side-window"
    static let FRONT_DRIVER_WINDOW = "driver-side-window"
    static let HOOD = "hood"
    static let SLIDE_DOOR = "slide-door"
    static let DRIVER_VAN_SIDE = "driver-side"
    static let PASSENGER_VAN_SIDE = "passenger-side"
}


struct VehicleType {
    static let CAR = "car"
    static let VAN = "van"
}


struct Vimeo {
    static let UPLOAD_VIDEO = "https://api.vimeo.com/me/videos"
    static let VIMEO_ACCES_TOKEN = ApiConstants.staging ? "7fa97d762fef3667677d6115db004861" : "83791ebf5f866f07d6b7f1da7bc5e64c"
    static let RES_UPLOAD_LINK_SECURE = "upload_link_secure"
    static let RES_TICKET_ID = "ticket_id"
    static let RES_LINK = "link"
}


struct Model {
    static let ACTIVE = "active"
    static let JOBS = "jobs"
    static let STATUS = "status"
    static let STATE = "state"
    static let STEP = "step"
    static let NAME = "name"
    static let CHECKED = "checked"
    static let LABEL = "label"
    
    //GENERIC
    static let DRIVER_ID = Api.DRIVER_ID
    static let ID = "id"
    static let TITLE = "title"
    static let NOTES = "notes"
    static let TEXT = "text"
    static let IDENTIFIER = "identifier"
    static let OPTIONS = "options"
    static let SELECTED = "selected"
    static let DESC = "description"
    static let MAXIMUM = "maximum"
    static let MINIMUM = "minimum"
    static let VALUE = "value"
    static let UNITS = "units"
    static let PHOTO_NAMES = "photo_names"
    
    static let PAPERWORK = "paperwork"
    
    //SIGNATURE
    static let DATE_SIGNED = "date_signed"
    static let SIGNED_BY = "signed_by"
    static let SIGNATURE = "signature"
    
    
    //APPRAISAL
    static let MANUAL_APPRAISAL = "manual_appraisal"
    static let VIDEO_APPRAISAL = "video_appraisal"
    static let THUMBNAIL = "thumbnail_base64"
    static let VIDEOS = "videos"
    static let VIDEO_NAME = "video_name"
    static let VIMEO_LINK = "vimeo_link"
    static let MILEAGE = "mileage"
    static let PETROL_LEVEL = "petrol_level"
    static let WARNING_LIGHT = "warning_light"
    static let MANUAL_ENTRY = "manual_entry"
    static let DAMAGES = "damages"
    static let VEHICLE_PARTS = "vehicle_parts"
    static let VEHICLE_DETAILS_SECTION = "vehicle_detail_section"
    static let VEHICLE_DETAILS_ROW = "vehicle_detail_row"
    
    //EXPENSES
    static let EXPENSES = "expenses"
    static let COST = "cost_in_pence"
    static let ITEM_DESCRIPTION = "description"
    static let PHOTO_NAME = "photo_name"
    static let UPLOADCARE_PHOTO_NAME = "uploadcare_image_url"
}



