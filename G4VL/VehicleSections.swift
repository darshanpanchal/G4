//
//  VehicleSections.swift
//  G4VL
//
//  Created by Foamy iMac7 on 06/09/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import Foundation


class VehicleSections  {
    
    //This class provides a place to keep the hardcoded vehicle sections and their images.
    static func getFront(vehicleType:String) -> [VehicleImage] {
        
        var a : [VehicleImage] = []

        if vehicleType == VehicleType.CAR {
            
            a = [
                VehicleImage(part: CarParts.WINDSCREEN, mainImage: "windscreen_front", focusImage: "windscreen_focus", enable: true),
                VehicleImage(part: CarParts.DRIVER_HEAD_LIGHT, mainImage: "left_light_front", focusImage: "left_headlight_focus", enable: true),
                VehicleImage(part: CarParts.PASSENGER_HEAD_LIGHT, mainImage: "right_light_front", focusImage: "right_head_light_focus", enable: true),
                VehicleImage(part: CarParts.HOOD, mainImage: "bonnet_front", focusImage: "bonnet_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_BUMPER, mainImage: "bumper_front", focusImage: "bumper_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_DRIVER_TYRE, mainImage: "front_left_tyre", focusImage: "", enable: false),
                VehicleImage(part: CarParts.FRONT_PASSENGER_TYRE, mainImage: "front_right_tyre", focusImage: "", enable: false),
                VehicleImage(part: CarParts.ROOF, mainImage: "front_roof", focusImage: "", enable: false),
                VehicleImage(part: CarParts.PASSENGER_WING_MIRROR, mainImage: "right_wing_front", focusImage: "right_wing_focus", enable: true),
                VehicleImage(part: CarParts.DRIVER_WING_MIRROR, mainImage: "right_wing_left", focusImage: "left_wing_focus", enable: true),
                VehicleImage(part: nil, mainImage: "front_remaining", focusImage: "", enable: false)
            ]
            
        }
        else if vehicleType == VehicleType.VAN {
            
            a = [
                VehicleImage(part: VanParts.HOOD, mainImage: "van_front_bonnet", focusImage: "van_bonnet_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_BUMPER, mainImage: "van_front_bumper", focusImage: "van_front_bumper_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_HEAD_LIGHT, mainImage: "van_front_driver_headlight", focusImage: "van_driver_headlight_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_HEAD_LIGHT, mainImage: "van_front_passenger_headlight", focusImage: "van_passenger_headlight_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_WING_MIRROR, mainImage: "van_front_passenger_wing_mirror", focusImage: "van_passenger_wing_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_WING_MIRROR, mainImage: "van_front_driver_wing_mirror", focusImage: "van_driver_wing_focus", enable: true),
                VehicleImage(part: VanParts.WINDSCREEN, mainImage: "van_front_windscreen", focusImage: "van_windscreen_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_PASSENGER_TYRE, mainImage: "van_front_passenger_tyre", focusImage: "van_front_tyre_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_DRIVER_TYRE, mainImage: "van_front_driver_tyre", focusImage: "van_front_tyre_focus", enable: true),
                VehicleImage(part: nil, mainImage: "van_front", focusImage: "", enable: false)
            ]
            
        }
        
        return a
    }
    
    
    static func getBack(vehicleType:String) -> [VehicleImage] {
        
        var a : [VehicleImage] = []
        
        if vehicleType == VehicleType.CAR {
            a = [
                VehicleImage(part: CarParts.BACK_LIGHT_PASSENGER, mainImage: "back_passenger_tail_light", focusImage: "passenger_tail_light_focus", enable: true),
                VehicleImage(part: CarParts.BACK_LIGHT_DRIVER, mainImage: "back_driver_tail_light", focusImage: "driver_tail_light_focus", enable: true),
                VehicleImage(part: CarParts.REAR_WINDOW, mainImage: "back_rear_window", focusImage: "rear_window_focus", enable: true),
                VehicleImage(part: CarParts.BOOT, mainImage: "boot", focusImage: "boot_focus", enable: true),
                VehicleImage(part: CarParts.DRIVER_WING_MIRROR, mainImage: "back_driver_side_mirror", focusImage: "left_wing_focus", enable: true),
                VehicleImage(part: CarParts.PASSENGER_WING_MIRROR, mainImage: "back_passenger_side_mirror", focusImage: "right_wing_focus", enable: true),
                VehicleImage(part: CarParts.BACK_BUMPER, mainImage: "back_rear_bumper", focusImage: "rear_bumper_focus", enable: true),
                VehicleImage(part: CarParts.BACK_DRIVER_TYRE, mainImage: "back_driver_rear_tyre", focusImage: "back_tyre_focus", enable: false),
                VehicleImage(part: CarParts.BACK_PASSENGER_TYRE, mainImage: "back_passenger_rear_tyre", focusImage: "back_tyre_focus", enable: false),
                VehicleImage(part: nil, mainImage: "full_rear", focusImage: "", enable: false)
            ]
            
        }
        else if vehicleType == VehicleType.VAN {
            
            a = [
                VehicleImage(part: VanParts.PASSENGER_WING_MIRROR, mainImage: "van_rear_passenger_mirror", focusImage: "van_passenger_wing_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_WING_MIRROR, mainImage: "van_rear_driver_mirror", focusImage: "van_driver_wing_focus", enable: true),
                VehicleImage(part: VanParts.BACK_LIGHT_PASSENGER, mainImage: "van_rear_passenger_light", focusImage: "van_rear_passengers_light_focus", enable: true),
                VehicleImage(part: VanParts.BACK_LIGHT_DRIVER, mainImage: "van_rear_driver_light", focusImage: "van_rear_drivers_light_focus", enable: true),
                VehicleImage(part: VanParts.BACK_DOOR, mainImage: "van_rear_doors", focusImage: "van_rear_doors_focus", enable: true),
                VehicleImage(part: VanParts.BACK_BUMPER, mainImage: "van_rear_rear_bumper", focusImage: "van_rear_bumper_focus", enable: true),
                VehicleImage(part: VanParts.BACK_DRIVER_TYRE, mainImage: "van_rear_driver_tyre", focusImage: "van_back_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_PASSENGER_TYRE, mainImage: "van_rear_passenger_tyre", focusImage: "van_back_tyre_focus", enable: true),
                VehicleImage(part: nil, mainImage: "van_rear_full", focusImage: "", enable: false)
            ]
            
        }
        return a
    }

    
    
    
    static func getDriverSide(vehicleType:String, slideDoor:Bool) -> [VehicleImage] {
        
        var a : [VehicleImage] = []
        
        if vehicleType == VehicleType.CAR {
            
            a = [
                VehicleImage(part: CarParts.ROOF, mainImage: "side_roof", focusImage: "", enable: false),
                VehicleImage(part: CarParts.WINDSCREEN, mainImage: "side_windscreen", focusImage: "windscreen_focus", enable: false),
                VehicleImage(part: CarParts.DRIVER_WING_MIRROR, mainImage: "side_wing_mirror", focusImage: "right_wing_focus", enable: true),
                VehicleImage(part: CarParts.DRIVER_HEAD_LIGHT, mainImage: "side_front_light", focusImage: "right_head_light_focus", enable: true),
                VehicleImage(part: CarParts.BACK_LIGHT_DRIVER, mainImage: "side_back_light", focusImage: "driver_tail_light_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_BUMPER, mainImage: "side_front_bumper", focusImage: "bumper_focus", enable: true),
                VehicleImage(part: CarParts.HOOD, mainImage: "side_bonnet", focusImage: "bonnet_focus", enable: true),
                VehicleImage(part: CarParts.BACK_DRIVER_WINDOW, mainImage: "side_back_window", focusImage: "back_window_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_DRIVER_WINDOW, mainImage: "side_front_window", focusImage: "front_window_focus", enable: true),
                VehicleImage(part: CarParts.BACK_DRIVER_DOOR, mainImage: "side_back_door", focusImage: "back_door_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_DRIVER_DOOR, mainImage: "side_front_door", focusImage: "front_door_focus", enable: true),
                VehicleImage(part: CarParts.BACK_DRIVER_ALLOY, mainImage: "side_back_alloy", focusImage: "back_alloy_focus", enable: true),
                VehicleImage(part: CarParts.BACK_DRIVER_TYRE, mainImage: "side_back_trye", focusImage: "back_tyre_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_DRIVER_ALLOY, mainImage: "side_front_alloy", focusImage: "front_alloy_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_DRIVER_TYRE, mainImage: "side_front_tyre", focusImage: "front_tyre_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_DRIVER_PANEL, mainImage: "side_front_panel", focusImage: "front_panel_focus", enable: true),
                VehicleImage(part: CarParts.BACK_DRIVER_PANEL, mainImage: "side_back_panel", focusImage: "back_panel_focus", enable: true),
                VehicleImage(part: nil, mainImage: "side_full", focusImage: "", enable: false)
                
            ]
           
            
        }
        else if vehicleType == VehicleType.VAN {
            a = [
                VehicleImage(part: VanParts.FRONT_DRIVER_WINDOW, mainImage: "van_side_window", focusImage: "van_window_focus", enable: true),
                VehicleImage(part: VanParts.WINDSCREEN, mainImage: "van_side_windscreen", focusImage: "van_windscreen_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_DOOR, mainImage: "van_side_door", focusImage: "van_door_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_HEAD_LIGHT, mainImage: "van_side_headlight", focusImage: "van_driver_headlight_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_DRIVER_ALLOY, mainImage: "van_side_front_alloy", focusImage: "van_front_alloy_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_BUMPER, mainImage: "van_side_front_bumper", focusImage: "van_front_bumper_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_FRONT_PANEL, mainImage: "van_side_front_panel", focusImage: "van_front_panel_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_DRIVER_TYRE, mainImage: "van_side_front_tyre", focusImage: "van_front_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_DRIVER_ALLOY, mainImage: "van_side_rear_alloy", focusImage: "van_back_alloy_focus", enable: true),
                VehicleImage(part: VanParts.BACK_BUMPER, mainImage: "van_side_rear_bumper", focusImage: "van_rear_bumper_focus", enable: true),
                VehicleImage(part: VanParts.BACK_DRIVER_TYRE, mainImage: "van_side_rear_tyre", focusImage: "van_back_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_LIGHT_DRIVER, mainImage: "van_side_tail_light", focusImage: "van_rear_drivers_light_focus", enable: true),
                VehicleImage(part: VanParts.DRIVER_WING_MIRROR, mainImage: "van_side_wing_mirror", focusImage: "van_driver_wing_focus", enable: true)
            ]
            if slideDoor {
                a.append(VehicleImage(part: VanParts.SLIDE_DOOR, mainImage: "van_slide_door", focusImage: "slide_door_focus", enable: true))
                a.append(VehicleImage(part: VanParts.DRIVER_VAN_SIDE, mainImage: "van_side", focusImage: "van_side_with_slide_focus", enable: true))
            }
            else {
                a.append(VehicleImage(part: VanParts.DRIVER_VAN_SIDE, mainImage: "van_side", focusImage: "van_side_focus", enable: true))
            }
            a.append(VehicleImage(part: nil, mainImage: "van_full", focusImage: "", enable: false))
            
        }
        
        
        return a
    }

    static func getPassengerSide(vehicleType:String, slideDoor:Bool) -> [VehicleImage] {
        
        var a : [VehicleImage] = []
        
        if vehicleType == VehicleType.CAR {
            
            a = [
                VehicleImage(part: CarParts.ROOF, mainImage: "side_roof", focusImage: "", enable: false),
                VehicleImage(part: CarParts.WINDSCREEN, mainImage: "side_windscreen", focusImage: "windscreen_focus", enable: false),
                VehicleImage(part: CarParts.PASSENGER_WING_MIRROR, mainImage: "side_wing_mirror", focusImage: "left_wing_focus", enable: true),
                VehicleImage(part: CarParts.PASSENGER_HEAD_LIGHT, mainImage: "side_front_light", focusImage: "left_headlight_focus", enable: true),
                VehicleImage(part: CarParts.BACK_LIGHT_PASSENGER, mainImage: "side_back_light", focusImage: "passenger_tail_light_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_BUMPER, mainImage: "side_front_bumper", focusImage: "bumper_focus", enable: true),
                VehicleImage(part: CarParts.HOOD, mainImage: "side_bonnet", focusImage: "bonnet_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_TYRE, mainImage: "side_back_trye", focusImage: "back_tyre_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_WINDOW, mainImage: "side_back_window", focusImage: "back_window_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_WINDOW, mainImage: "side_front_window", focusImage: "front_window_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_DOOR, mainImage: "side_back_door", focusImage: "back_door_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_DOOR, mainImage: "side_front_door", focusImage: "front_door_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_ALLOY, mainImage: "side_front_alloy", focusImage: "front_alloy_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_PANEL, mainImage: "side_front_panel", focusImage: "front_panel_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_TYRE, mainImage: "side_front_tyre", focusImage: "front_tyre_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_ALLOY, mainImage: "side_back_alloy", focusImage: "back_alloy_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_PANEL, mainImage: "side_back_panel", focusImage: "back_panel_focus", enable: true),
                VehicleImage(part: nil, mainImage: "side_full", focusImage: "", enable: false)
            ]
            
        } else if vehicleType == VehicleType.VAN {
            a = [
                VehicleImage(part: VanParts.FRONT_PASSENGER_WINDOW, mainImage: "van_side_window", focusImage: "van_window_focus", enable: true),
                VehicleImage(part: VanParts.WINDSCREEN, mainImage: "van_side_windscreen", focusImage: "van_windscreen_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGERS_DOOR, mainImage: "van_side_door", focusImage: "van_door_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_HEAD_LIGHT, mainImage: "van_side_headlight", focusImage: "van_passenger_headlight_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_PASSENGER_ALLOY, mainImage: "van_side_front_alloy", focusImage: "van_front_alloy_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_BUMPER, mainImage: "van_side_front_bumper", focusImage: "van_front_bumper_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_FRONT_PANEL, mainImage: "van_side_front_panel", focusImage: "van_front_panel_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_PASSENGER_TYRE, mainImage: "van_side_front_tyre", focusImage: "van_front_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_PASSENGER_ALLOY, mainImage: "van_side_rear_alloy", focusImage: "van_back_alloy_focus", enable: true),
                VehicleImage(part: VanParts.BACK_BUMPER, mainImage: "van_side_rear_bumper", focusImage: "van_rear_bumper_focus", enable: true),
                VehicleImage(part: VanParts.BACK_PASSENGER_TYRE, mainImage: "van_side_rear_tyre", focusImage: "van_back_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_LIGHT_PASSENGER, mainImage: "van_side_tail_light", focusImage: "van_rear_passengers_light_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_WING_MIRROR, mainImage: "van_side_wing_mirror", focusImage: "van_passenger_wing_focus", enable: true)
            ]
            if slideDoor {
                a.append(VehicleImage(part: VanParts.SLIDE_DOOR, mainImage: "van_slide_door", focusImage: "slide_door_focus", enable: true))
                a.append(VehicleImage(part: VanParts.PASSENGER_VAN_SIDE, mainImage: "van_side", focusImage: "van_side_with_slide_focus", enable: true))
            }
            else {
                a.append(VehicleImage(part: VanParts.PASSENGER_VAN_SIDE, mainImage: "van_side", focusImage: "van_side_focus", enable: true))
            }
            a.append(VehicleImage(part: nil, mainImage: "van_full", focusImage: "", enable: false))
            
        }
        
        
        return a
    }
    
    static func getTop(vehicleType:String) -> [VehicleImage] {
        
        var a : [VehicleImage] = []
        
        if vehicleType == VehicleType.CAR {
            
            a = [
                VehicleImage(part: CarParts.HOOD, mainImage: "top_bonnet", focusImage: "bonnet_focus", enable: true),
                VehicleImage(part: CarParts.BOOT, mainImage: "top_boot", focusImage: "boot_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_WINDOW, mainImage: "top_passenger_rear_window", focusImage: "back_window_focus", enable: false),
                VehicleImage(part: CarParts.FRONT_DRIVER_WINDOW, mainImage: "top_driver_front_window", focusImage: "front_window_focus", enable: false),
                VehicleImage(part: CarParts.DRIVER_HEAD_LIGHT, mainImage: "top_driver_head_light", focusImage: "", enable: false),
                VehicleImage(part: CarParts.FRONT_PASSENGER_WINDOW, mainImage: "top_passenger_front_window", focusImage: "", enable: false),
                VehicleImage(part: CarParts.BACK_DRIVER_WINDOW, mainImage: "top_driver_rear_window", focusImage: "", enable: false),
                VehicleImage(part: CarParts.BACK_LIGHT_DRIVER, mainImage: "top_driver_tail_light", focusImage: "", enable: false),
                VehicleImage(part: CarParts.FRONT_BUMPER, mainImage: "top_front_bumper", focusImage: "", enable: false),
                VehicleImage(part: CarParts.BACK_PASSENGER_DOOR, mainImage: "top_passenger_back_door", focusImage: "", enable: false),
                VehicleImage(part: CarParts.FRONT_PASSENGER_DOOR, mainImage: "top_passenger_front_door", focusImage: "", enable: false),
                VehicleImage(part: CarParts.BACK_DRIVER_DOOR, mainImage: "top_driver_back_door", focusImage: "", enable: false),
                VehicleImage(part: CarParts.FRONT_DRIVER_DOOR, mainImage: "top_driver_front_door", focusImage: "", enable: false),
                VehicleImage(part: CarParts.PASSENGER_HEAD_LIGHT, mainImage: "top_passenger_head_light", focusImage: "", enable: false),
                VehicleImage(part: CarParts.BACK_LIGHT_PASSENGER, mainImage: "top_passenger_tail_light", focusImage: "", enable: false),
                VehicleImage(part: CarParts.REAR_WINDOW, mainImage: "top_rear_window", focusImage: "rear_window_focus", enable: true),
                VehicleImage(part: CarParts.ROOF, mainImage: "top_roof", focusImage: "roof_focus", enable: true),
                VehicleImage(part: CarParts.WINDSCREEN, mainImage: "top_windscreen", focusImage: "windscreen_focus", enable: true),
                VehicleImage(part: nil, mainImage: "top_full", focusImage: "", enable: false)
            ]
            
        }
       
        
        return a
    }
    
    static func getInside(vehicleType:String, slideDoor:Bool) -> [VehicleImage] {
        
        var a : [VehicleImage] = []
        
        if vehicleType == VehicleType.CAR {
            
            a = [
                VehicleImage(part: CarParts.INSIDE, mainImage: "inside", focusImage: "inside_focus", enable: true),
                VehicleImage(part: CarParts.ROOF, mainImage: "side_roof", focusImage: "", enable: false),
                VehicleImage(part: CarParts.WINDSCREEN, mainImage: "side_windscreen", focusImage: "windscreen_focus", enable: false),
                VehicleImage(part: CarParts.PASSENGER_WING_MIRROR, mainImage: "side_wing_mirror", focusImage: "left_wing_focus", enable: true),
                VehicleImage(part: CarParts.PASSENGER_HEAD_LIGHT, mainImage: "side_front_light", focusImage: "left_headlight_focus", enable: true),
                VehicleImage(part: CarParts.BACK_LIGHT_PASSENGER, mainImage: "side_back_light", focusImage: "", enable: true),
                VehicleImage(part: CarParts.FRONT_BUMPER, mainImage: "side_front_bumper", focusImage: "bumper_focus", enable: true),
                VehicleImage(part: CarParts.HOOD, mainImage: "side_bonnet", focusImage: "bonnet_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_ALLOY, mainImage: "side_back_alloy", focusImage: "back_alloy_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_PANEL, mainImage: "side_back_panel", focusImage: "back_panel_focus", enable: true),
                VehicleImage(part: CarParts.BACK_PASSENGER_TYRE, mainImage: "side_back_trye", focusImage: "back_tyre_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_ALLOY, mainImage: "side_front_alloy", focusImage: "front_alloy_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_ALLOY, mainImage: "side_front_panel", focusImage: "front_panel_focus", enable: true),
                VehicleImage(part: CarParts.FRONT_PASSENGER_TYRE, mainImage: "side_front_tyre", focusImage: "front_tyre_focus", enable: true),
                VehicleImage(part: nil, mainImage: "side_full", focusImage: "", enable: false)
            ]
            
        } else if vehicleType == VehicleType.VAN {
            a = [
                VehicleImage(part: VanParts.INSIDE, mainImage: "van_inside", focusImage: "van_inside_focus", enable: true),
                VehicleImage(part: VanParts.WINDSCREEN, mainImage: "van_side_windscreen", focusImage: "van_windscreen_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_HEAD_LIGHT, mainImage: "van_side_headlight", focusImage: "van_passenger_headlight_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_PASSENGER_ALLOY, mainImage: "van_side_front_alloy", focusImage: "van_front_alloy_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_BUMPER, mainImage: "van_side_front_bumper", focusImage: "van_front_bumper_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_FRONT_PANEL, mainImage: "van_side_front_panel", focusImage: "van_front_panel_focus", enable: true),
                VehicleImage(part: VanParts.FRONT_PASSENGER_TYRE, mainImage: "van_side_front_tyre", focusImage: "van_front_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_PASSENGER_ALLOY, mainImage: "van_side_rear_alloy", focusImage: "van_back_alloy_focus", enable: true),
                VehicleImage(part: VanParts.BACK_BUMPER, mainImage: "van_side_rear_bumper", focusImage: "van_rear_bumper_focus", enable: true),
                VehicleImage(part: VanParts.BACK_PASSENGER_TYRE, mainImage: "van_side_rear_tyre", focusImage: "van_back_tyre_focus", enable: true),
                VehicleImage(part: VanParts.BACK_LIGHT_PASSENGER, mainImage: "van_side_tail_light", focusImage: "van_rear_passengers_light_focus", enable: true),
                VehicleImage(part: VanParts.PASSENGER_WING_MIRROR, mainImage: "van_side_wing_mirror", focusImage: "van_passenger_wing_focus", enable: true)
                
                
            ]
            if slideDoor {
                a.append(VehicleImage(part: VanParts.SLIDE_DOOR, mainImage: "van_slide_door", focusImage: "slide_door_focus", enable: true))
                a.append(VehicleImage(part: VanParts.PASSENGER_VAN_SIDE, mainImage: "van_side", focusImage: "van_side_with_slide_focus", enable: true))
            }
            else {
                a.append(VehicleImage(part: VanParts.PASSENGER_VAN_SIDE, mainImage: "van_side", focusImage: "van_side_focus", enable: true))
            }
            a.append(VehicleImage(part: nil, mainImage: "van_full", focusImage: "", enable: false))
            
        }
        
        
        return a
    }
    
    
    static func readibleCarParts(part:String)->String {
        
        if AppManager.sharedInstance.currentJob != nil && AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal != nil  && AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts != nil{
            let vehiclePart = AppManager.sharedInstance.currentJobAppraisal!.manualAppraisal!.pickup.vehicleParts!.filter {
                return $0.name == part
            }
            if vehiclePart.count != 0 {
                return vehiclePart.first!.label ?? ""
            }
        }
        
        
        return part.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ").capitalizingFirstLetter()
        
    }
}
