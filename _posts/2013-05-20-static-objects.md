---
layout: post
title: Should I make this object a singleton? 
date: 2013-05-20 10:30:00 +10:00
description: Some thoughts on class design and limitations you might face
permalink: /blog/should-i-make-this-object-a-singleton.html
icon: /img/main/me.jpg
comments: true
---

**Note**: This is just a first pass on the post, as I need to touch on various tools I've used in the past to identify these constraints. But let's start with the concepts.

Someone asked me a question yesterday along the lines of, well, this:

<blockquote class="twitter-tweet" data-conversation="none"><p>@<a href="https://twitter.com/nickhodgemsft">nickhodgemsft</a> Roger, cheers @<a href="https://twitter.com/shiftkey">shiftkey</a> thoughts? Will it be better to create a life long Crypto obj rather than this <a href="http://t.co/bn3hRIiGdt" title="http://twitter.com/HDizzle84/status/336104817707589633/photo/1">twitter.com/HDizzle84/stat…</a></p>&mdash; HDizzle (@HDizzle84) <a href="https://twitter.com/HDizzle84/status/336104817707589633">May 19, 2013</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

So I wanted to put together a simple guide on how to determine *when* the [Singleton pattern](http://en.wikipedia.org/wiki/Singleton_pattern) is a suitable use case - yes, it gets a bad reputation due to misuse, but there are some scenarios where it does add value (and is often necessary).

## How expensive is it to create?

Imagine you have a database connection - say [SqlConnection](http://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnection.aspx) - and you create an instance of it to connect to a database?

**TODO:** show windbg object dump of a SqlConnection object

Inside this SqlConnection object you should see a bunch of underlying resources - these are the components which make the magic happen when you perform a "SELECT * FROM Table" in your application.

Many of the objects you create in your application are probably simpler than this - classes to hold data, for example - but once you start interacting with the underlying platform and identify various bottlenecks in your applications understanding what resources are hiding where is invaluable knowledge.

The other thing to keep in mind with objects is what they represent. If your classes interacts with the network, storage or attached devices, for example, you are likely to face specific constraints with how you use these resources. 

An example: if you're ever making concurrent web requests to a specific domain, .NET will actually throttle you to two concurrent requests. You can change this if you [know where to look](http://msdn.microsoft.com/en-us/library/fb6y0fyc.aspx) but the defaults are designed to be "good enough" for most scenarios.

Another example: [database connection pools](http://msdn.microsoft.com/en-us/library/8xx3tyca.aspx) - a finite number of connections which are maintained and reused over the lifetime of an application - instead of arbitrarily creating, using, and then destroying connections each time we need them. 

## What about my memory footprint?

So assuming the previous two constraints aren't affecting your code, sure, you might be able to get away with creating objects whenever necessary.

But what if you're making a mobile app? Memory becomes a significant constraint on any mobile applications - and the more moving parts you have in a mobile application, the more you need to optimise to reduce the impact of those moving parts.

> I don't need to worry about that, my stack has generational garbage collection (GC).

But that's not actually a solution - more like a crutch. GC isn't a free lunch - it's overhead that you're now invoking periodically (technically GC will run whenever it needs to, which is often at the worst possible time due to memory pressure) because you were lazy with how you structured your application. 

**TODO:** demonstrate .NET performance counters around GC, with a sample that does stupid things

## What about multi-threaded code?

This is the hardest part to discuss, because multi-threaded code is hard. Really hard.

If your object is [immutable](http://en.wikipedia.org/wiki/Immutable_object) (that is, you can call the same function on an object **as many times as possible until the end of time** and you'll always get the same result) then it might be possible for it to be used as a singleton object.

**TODO:** discuss multi-threaded hooha annoyances

## But I just want to use it as a global object

Please don't. This introduces unnecessary coupling into your application, at the value of saving a few keystrokes.

**TODO:** explain the god object pattern and why it is bad

**TODO:** outline where this is utterly unavoidable and you need to suck it up and just God Object that sucker

## What's the damn answer, Brendan?

Ok, so if you've read this far - I thank you.

So when you should consider making a class or object into a singleton?

 - If it's expensive to create, consider it.
 - If it's touching underlying system resources, consider it.
 - If you need to optimise for memory usage, consider it.
 - Go learn how multi-threading *actually* works - no, the TPL is cheating.

## Feedback is Welcome

Did I miss something? Get something wrong? 

Leave a comment and let me know.
