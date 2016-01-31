---
layout: post
title: Using Rx to Implement Filtering in MahTweets
permalink: /using-rx-to-implement-filtering-in-mahtweets.html
description: A thought process about leveraging the Rx Framework to implement a new filtering solution for MahTweets vNext.
date: 2011-02-19 14:00:00 +11:00
tags: "mahtweets reactive-extensions "
comments: true
---

As we're kicking development off for the next version of MahTweets in the coming weeks, the team has been looking at experimenting with new technology and bringing the most useful stuff into the application.

Filtering is one of the things that MahTweets is famous for, but we're always looking for ways to make it better and easier. We've been experimenting with using the [Reactive Extensions (Rx) for .NET][1] to simplify the entire pipeline and provide more freedom in the application.

## The Current Status

MahTweets allow the user to filter streams by update type, contact or text. Filters can be applied to individual streams or globally.

Roughly speaking, this is how the filters are applied.

<center><a href="img/posts/FiltersClassic.png"><img src="img/posts/FiltersClassic.png" width="700" /></a></center>

Updates from external services are added to the queue, which then raises CollectionChangedEvent notifications to each views. The view is responsible for running an update through its configured filters.

Limitations about this approach:

- Global Ignores were implemented separately.
- Custom filtering was implemented per update type.
- UI was coupled to stream container and specific parameters.

## First Cut using Rx

FYI: If you're not familiar with the Observer Pattern, check out the [Wikipedia article][2] for starters. Rx uses the Observer pattern heavily.

We had a habit of using the phrase "filter" in many places of the application. To clarify our intent, we introduced two specific interfaces:

 - **IStatusSubscriber** - an extension which subscribes to a stream of incoming requests.
 - **IConditionalSubscriber** : **IStatusSubscriber** - an extension which filters the updates before propogating to its consumers. Pass-thru or exclude filters can be specified.

Replacing the Queue of messages with an IObservable/IObserver dual allows the application to leverage the Subject&lt;T&gt; class to manage the interactions between the services and the clients. This class resides in System.Reactive.dll and implements both IObservable&lt;T&gt; and IObserver&lt;T&gt;.

MahTweets also had some demo plugins for stream analytics, and abstracting away the queue support allows the application to plug in additional "global" services, using the same interfaces. Rx also allows observers to specify which thread to execute on, so the usage of the Dispatcher, TaskPool or ThreadPool (depending on scenario) can be configured without any plumbing code.

The interactions between these components now looks like:

<center><a href="img/posts/RxFirstCut.png"><img src="img/posts/RxFirstCut.png" width="700" /></a></center>

The biggest change is that subscribers interact with the IObservable, rather than being encompassed within the view. Each list still combines a set of filters, which display the combined set of results on-screen. However, when multiple filters are run in parallel, invalid items may appear.

Limitations about this approach:

 - Excluded updates may be propogated through other subscribers in the same view.
 - Global Ignores still not supported.

## Back to the Drawing Board

So after some shut-eye and sun, I revisited the initial design for the IObservable implementation. What stood out to me was that:

 - Include and exclude side-by-side has always been somewhat complex - both for users to understand, and determining which takes priority.
 - Include and exclude filters didn't need to exist in the same location.
 - Rx can support chaining observers, however...
 - Chaining isn't what the Observer pattern is about.

After some more musing, I formed an opinion about subscriber rules (only mine so far):

**An exclude rule is applied globally. An include rule is applied locally.**

From my experiences with using Twitter, the typical use cases for exclude filters are:

 - "Great, another Twitter spam concept..." *looks at paper.li*
 - "Person XYZ is tweeting too much right now. I don't want to hear him for a while..."
 - "Oops, I said the i-word and the spammers are out and about..."

On the other hand, the use cases for include filters can be like:

 - "I want to see what *this* group of contacts is talking about..."
 - "I want to see tweets mentioning 'ABC' - (side note: more on search later)..."
 - "I want to see my mentions/messages..."

Compare and contract (perhaps your experiences differ).

## Second Cut using Rx

The second cut of the design allows for three subscriber hooks:

- Subscribers register against the source observable, without any filtering applied.
- Subscribers register against the output observable, with the global filtering applied.
- Exclude rules are applied closer to the source.

<center><a href="img/posts/RxSecondCut.png"><img src="img/posts/RxSecondCut.png" width="700" /></a></center>

An internal subscriber verifies a status against a list of exclusions, and propogates the status further if it is valid. Each view only requires its inclusion rules (or a wildcard rule if no rules specified) to display results.

## The Next Step

 - Debate with [@aeoth][3] on this
 - Performance Testing against a large set of data.
 - Demonstrating how external plugins can include their own rules.
 - Demonstrate user interface changes for vNext.

[1]: http://msdn.microsoft.com/en-us/devlabs/ee794896
[2]: http://en.wikipedia.org/wiki/Observer_pattern
[3]: http://twitter.com/aeoth
