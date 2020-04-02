<p>

 [![Build Status](https://app.bitrise.io/app/3baabd16bba9e290.svg?token=mo_bjE8kB8bJ2h6K6wKJXA)](https://app.bitrise.io/app/3baabd16bba9e290#/buildsÂ)
<img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
 <img src="https://img.shields.io/badge/platform-iOS_10.1-brightgreen.svg?style=flat" alt="iOS 10.0" />
</p>

# iOS application to help fight COVID-19



This app is aiming at helping fight COVID-19 spread by collecting anonymous data about people meeting each other.

In the basic scenario, the device is emitting an iBeacon signal (Bluetooth low energy) and at the same time listens to iBeacons around you. Thus creating an anonymous mesh of who met whom and when. This data is collected on server and when a person is positively diagnosed with SARS-CoV-2 (the infamous "corona" virus causing COVID-19 disease), the server will notify via push all the devices that were in a close and significant proximity with that person.

Alternatively, the user can flag himself as quarantined in which case the app will regularly check his/her GPS location and warn him/her in case he/she leaves the quarantine.

## Build prerequisities

* Install all required dependencies > run `pod install`
* Fill in `bundle identifier`
* Register your app in Google Firebase console and copy GoogleService-Info.plist file to app folder
* Add innovatrics license file. You can find more about the face recognition solutions here:  https://www.innovatrics.com/face-recognition-solutions/
* Save the world
