[![Swift Version][swift-image]][swift-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)  
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

# Valeo-Bachelorthesis
<br />
<p align="center">
  <img src="NewValeoLogo.png" alt="Logo" width="80" height="80">
</p>

This application is a working prototype for developing a system to collect and alayse nutrition of users.
It's not ment to be ready for use in production and is not developed by profesional doctors!  
A possibly updated version of this application can be downloaded from the AppStore [here](https://apps.apple.com/de/app/valeo-diary/id1556504769).



## Features

- [x] Different Login methods including Email, Anonymous and Sign in with Apple
- [x] Calorietracking
- [x] Dynamic userfeedback on nutrition
- [x] Dynamic search of nutrients
- [x] User overview
- [x] AI based nutrientrating

## Missing Features for production

- [ ] Medically correct questionnaire
- [ ] Improved AI for nutrientrating
- [ ] Large dataset of nutrients
- [ ] QR-code scanner for nutrientsearch
- [ ] Data exchange with other applications
- [ ] Usage of further medical userdata

## Requirements

- iOS 14.0+
- Xcode 12.0
- Google Firebase Account
- Algolia Account

## Setup

### Algolia Setup
Cerate an account at Algolia and add an application.
Now add an Index for the nutrients to your indices of the application.

### Firebase Setup
Create a new Firebase project and enable billing. Follow the instructions to create Cloud Functions. Use JavaScript for creating the functions.
Those are necessary to upload the nutreitns also to Algolia.
Replace the code in '''index.js''' with the following code:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const algoliasearch = require ('algoliasearch');

admin.initializeApp();

const client = algoliasearch('APPLICATION_ID', 'ADMIN_API_KEY');
const index = client.initIndex('NUTRIENT_INDEX');

exports.onNutrientCreated = functions
    .firestore
    .region('YOUR_REGION_OF_FIREBASE')
    .document('nutrient/{nutrientId}')
    .onCreate((snap, context) => {
    // Get the nutrient document
    const nutrient = snap.data();
  
     // Add an 'objectID' field which Algolia requires
   nutrient.objectID = context.params.nutrientId;
  
    // Write to the algolia index
   return index.saveObject(nutrient);
  });
```
Replace APPLICATION_ID with the Application Id from your algolia application.  
Replace ADMIN_API_KEY with your private ADMIN API Key from your algolia application.  
Replace NUTRIENT_INDEX with the index you created for the nutrients in your algolia application.  
Save the file and deploy your functions to Firebase with '''firebase deploy'''.  
A detailed instruction on how to create Cloud Functions in Firebase can be found [here](https://firebase.google.com/docs/functions).  
  
Go to Authentication settings and enable anonymous authentication and Sign in with Apple.  

#### Set up remote Push Notifications
If you want to be able to send push notifications you also have to enable Cloud Messaging.  
To use this feature you have to go to [https://firebase.google.com/docs/cloud-messaging](https://firebase.google.com/docs/cloud-messaging) and follow the instructions to enable this feature.

### XCode Project Setup

Configure your siging of the project.  
Create a class in Template '''APIKeys.swift'''.  
Add your custom Algolia keys to the class.  

```swift
import Foundation

public class APIKeys {
    // Algolia API Key
    public static let algoliaAppId = "ALGOLIA_API_KEY"
    // Algolia Search-Only API Key
    public static let algoliaApiKey = "ALGOLIA_SEARCHONLY_API_KEY"
}
```

Go to your project folder in Terminal and run 'pod install'.  

```console
foo@bar/valeo: $ pod install
```

Go to Firebase and add an IOS application to the project. Get the 'GoogleService_Info.plist' and add it to your project in the Template folder.  
Check in the Project file under Targets you have the capabilities of Background Modes(background Fetch, Remote notifications, Background preocessing) for push notifications, Push Notifications and Sign in with Apple added to your project.  
Now you should be able to run this application.  

### Add nutrient data to database
In order to load nutrient data into your database you can replace the content of '''WindowGroup { }''' in 'ValeoApp.swift' with  
'ContentView.swift' this will show you only one view to upload the JSOn data of the nutrients to Firebase. If the Cloud Function is up and running it should also add the nutrients to your Algolia search index so you can use the dynamic search.  
After uploading just discard the change in 'ValeoApp.swift' to use the application normally.  

### Add questions to database
In order to use the anamnesis feature of the app you have to provide some questions to load.  
The questions have to be in a collection called 'questions'.  
The first question has the index 0 and the last question has 0 has all indices for the next question.  
The structure of a question can be found in 'Question.swift'.  


## Used technologies

### Swift Frameworks
- [x] [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [x] [Combine](https://developer.apple.com/documentation/combine)

### Third party services
- [x] [Google Firebase](https://firebase.google.com/docs)
- [x] [Algolia](https://www.algolia.com/doc)

### Used dataset
- [x] [Nutritional values for common foods and products](https://www.kaggle.com/trolukovich/nutritional-values-for-common-foods-and-products)

## Licence

- [firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk/blob/master/LICENSE)
- [algolia/instantsearch-ios](https://github.com/algolia/instantsearch-ios/blob/master/LICENSE.md)
- [Nutritional values for common foods and products](https://creativecommons.org/publicdomain/zero/1.0)

# Bachelorthesis

My (german) bachelor thesis is about creating a mobile application to collect and analyze a users nutrition. It's written in [LaTeX](http://www.latex-project.org/).

__Title__: Valeo: Eine mobile Anwendung zum Erfassen und Analysieren der Ernährung

__University__: Ludwig-Maximilians-Universität Muenchen (University of Applied Sciences)

__Degree course__: Bachelor Informatik (Bachelor of Computer Science)

__Primary supervisor__: [Prof. Dr. François Bry](https://www.linkedin.com/in/francoisbry)


## Meta

Laurenz Hill – hill.laurenz@gmx.de


[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
