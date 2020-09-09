# RadarCOVID iOS App

<p align="center">
    <a href="https://github.com/RadarCOVID/radar-covid-ios/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/RadarCOVID/radar-covid-ios?style=flat"></a>
    <a href="https://github.com/RadarCOVID/radar-covid-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/RadarCOVID/radar-covid-ios?style=flat"></a>
    <a href="https://github.com/RadarCOVID/radar-covid-ios/blob/master/LICENSE" title="License"><img src="https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg?style=flat"></a>
</p>

## Introduction

Native iOS implementation of RadarCOVID contact tracing client using [DP3T iOS SDK](https://github.com/DP-3T/dp3t-sdk-ios)

## Prerequisites
These are the tools used to build the solution:
- Xcode 11.6

## Installation and Getting Started

The project can be built with the indicated Xcode version. Dependencies are managed with [Swift Package Manager](https://swift.org/package-manager), no further setup is needed.

### Provisioning

The project is configured for a specific provisioning profile. To install the app on your own device, you will have to update the settings using your own provisioning profile.

Apple's Exposure Notification framework requires a `com.apple.developer.exposure-notification` entitlement that will only be available to government entities. You will find more information in the [Exposure Notification Addendum](https://developer.apple.com/contact/request/download/Exposure_Notification_Addendum.pdf) and you can request the entitlement  [here](https://developer.apple.com/contact/request/exposure-notification-entitlement).

### Commit Lint
It's possible to install a git hook to automatically check commit comments based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

- Prerequisites: [Node](https://nodejs.org) , [Npm](https://www.npmjs.com/)
- Install hook:
	> $ npm install
- Generate changelog and tag release:
	> $ npm release

## Support and Feedback

The following channels are available for discussions, feedback, and support requests:

| Type       | Channel                                                |
| ---------- | ------------------------------------------------------ |
| **Issues** | <a href="https://github.com/RadarCOVID/radar-covid-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/RadarCOVID/radar-covid-ios?style=flat"></a> |

## Contribute

If you want to contribute with this exciting project follow the steps in [How to create a Pull Request in GitHub](https://opensource.com/article/19/7/create-pull-request-github).

More details in [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

This Source Code Form is subject to the terms of the [Mozilla Public License, v. 2.0](https://www.mozilla.org/en-US/MPL/2.0/).
