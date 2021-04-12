# FocusInspiring - The way of keeping inspirations ongoing

## App specification

### A reminder app for Inspirational Notes

This app allows you to store any inspiration coming up to your mind in form of text, image or screenshot. In a later version, it will also be possible to attach multiple documents and audio notes .

Helping you as a reminder for your inspirations the app displays the note again after a certain period of time like days, weeks, months - adjustable by yourself for each note. According to the state of your realization, you can then decide to add the note to a *List of Glory*, edit & restore for later on or delete it (e.g. when no longer applicable).

This way, you are free to focus on new inspirations neither having to worry losing great ideas nor having to actively search certain lists persistently or getting disturbed by frequent notifications.

You can use this app for developing your private projects or advancing your own business. Just as you can store motivational quotes and get an inspirational reminder within the app. These are just some examples of how one might use it.
Feel free to play around and use it according to your needs.


### Features

- Store various kinds of inspirational notes - currently these are: text, image/screenshot and camera snapshot

- Add a title to each note

- Search for an image from Flickr given a search term and add it

- Specify a time interval for redisplaying a note: in days, weeks, months, years

- Edit a presented note and respecify a time interval for next display

- Add notes successfully realized to the *List of Glory*

- Edit the *List of Glory* and open an item in detail view

- Delete notes that are no longer significant


### Libraries and Frameworks

- [CoreData](https://developer.apple.com/documentation/coredata)

- [Flickr](https://flickr.com/services/developer) (Searching & downloading images)


### User Interface

**todo**


### How to Build and Run


1. Download or clone the project on your desktop.

2. Provide an API Key for Flickr in the file [NetworkClient.swift](../main/FocusInspiring/Model/Network/NetworkClient.swift)

3. Open the project, build and run the app.

### Testing the app

In order to properly test the app, I have inserted shorter time units (seconds, minutes) for redisplaying an inspirational note item. Thus, you do not need to wait for at least a day till your added note item gets displayed.

Ensure that you give each note a title and at least some text description or image. Otherwise you will see some hint.


