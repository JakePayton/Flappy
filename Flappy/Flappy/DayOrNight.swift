//
//  DayOrNight.swift
//  Flappy
//
//  Created by Jake Payton on 10/25/14.
//  Copyright (c) 2014 Detroit Labs. All rights reserved.
//

import Foundation

func isDaytime() -> Bool {

    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
    let hour = components.hour
    let minutes = components.minute

    return hour >= 7 && hour <= 20
}

