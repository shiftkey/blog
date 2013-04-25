--- 
layout: post
title: On the Windows 8 Preview Video
permalink: /on-the-windows-8-preview.html
funnelweb_id: 15
date: 2011-06-08 14:00:00 +10:00
tags: "windows windows8 wpf silverlight"
icon: /img/main/win8.jpg
description: Some thoughts on the initial reaction to the announcement of HTML/JS within Windows 8
comments: true
---

For those who haven't seen it, this video was announced last week about how the Windows 8 UI is changing: [http://www.youtube.com/watch?v=p92QfWOw88I][1]

[1]: http://www.youtube.com/watch?v=p92QfWOw88I

It was the trigger for significant backlash - and not for what was said, but for what wasn't said around the other options available for building Windows applications.

## Yes, MSFT could have handled it better

Since the video dropped, developers and possibly everyone with a blog has been raising concerns about the other options available to developers for building Windows apps. The underlying vibe has been "everything else has been abandoned, the only option is now HTML5, the sky is falling and I have nothing to wear". I haven't watched the Sinofsky video (if it was even recorded), but when you see reporting like: 

> "The development platform is based on HTML5 and JavaScript." [Source][2]

[2]: http://news.cnet.com/8301-31021_3-20068119-260/sinofsky-shows-off-windows-8-at-d9/

and constrast with a different source:

> "Windows 8 essentially supports two kinds of applications. One is the classic Windows application, which runs in a desktop very similar to the Windows 7 desktop." [Source][3]

[3]: http://allthingsd.com/20110601/exclusive-making-sense-of-what-we-just-learned-about-windows-8/

then you know something got lost in the message.


## The sky is falling for *insert technology here*

[That thread][4]. Oh dear $deity, [that thread][5]. 

[4]: http://forums.silverlight.net/forums/t/230502.aspx
[5]: http://forums.silverlight.net/forums/p/230725/563975.aspx

I appreciate that the MSFT guys "in the field" are stuck between a rock and a hard place currently - they cannot provide details to answer people's concerns or questions, but are dealing with a large backlash due to the large amount that is not know currently. 

As one of those in the audience who has to wait, in uncertainty, between now and [BUILD][6] to have these questions answered, I wish they would rethink this decision and respond to questions and help change the course of discussion.

[6]: http://www.buildwindows.com/

While the video does mention:

> "Windows 8 also runs the existing Windows apps that you know and that you love"

it then follows up with running Excel.

Yep. Excel. 

While an Excel demo is a good indicator of the backwards compatibility that Windows is famous for, it was a jarring change from the rest of the video, and I'm not sure it was the best application to demonstrate.

Perhaps the developer story is not ready to show. Perhaps it was supposed to be about the shell, and HTML5 was only mentioned in passing. Perhaps, perhaps, perhaps. I suspect a demonstration of how a WPF/SL/Winforms/native application **could** look/feel/behave within the new shell would provide some information without giving much away. 

The video was about creating interest in the new platform and discussing the opportunities it provides. Now is the time to talk more broadly, while everyone is talking about it.


So instead of [drumming up more drama][7], I thought I'd share some takeaways for both sides on this:

 [7]: http://forums.silverlight.net/forums/t/230744.aspx

## Devs: pay attention to the user experience

I hope developers took away from this story how the user experience of applications has changed, and how the classic WIMP (Windows, Icons, Menu, Pointer) applications will be impacted. Much like the transition from Windows Mobile 6.5 to Windows Phone 7, I anticipate some growing pains once developers get their hands on the development tools.

Touch input is also something that many Windows developers may not be familiar with. While it has been available to native developers since Windows 7 launched, and was added to WPF and Silverlight with subsequent product releases, it hasn't really been utilized to anywhere near its full potential.

Get familiar with how gestures work - as a starting point, the WP7 emulator turns mouse inputs into touch inputs. Touch will be mandatory if you want an application to be usable on different form factors (Windows 8 is taking an iOS-ish route with the same codebase running on desktops, tablets and devices).


## MSFT: don't let the echo chamber continue

I'm still baffled by the decision to stonewall. Developers are customers, and they have questions. Why not be pro-active and help smooth the transition over the coming months? 

With all the strong and passionate opinions flying around, wouldn't it be good to plant some seeds of confidence and turn the conversation from "Where is XYZ?" to "What can I do with Windows 8 using XYZ?"

Give the community a baseline of information so they can start planning and start providing feedback. It doesn't have to be revealing all the cards, but the developer story for Windows 8 is (mostly) unknown currently. That's why people are concerned.

## MSFT: don't forget the hardware

I've been looking for a kick-arse tablet device to run Windows on for a while, but have been stuck in Goldilocks-mode - "too large, too heavy, the battery is too short, etc" - and continue to sit on the fence. Much like with WP7, I'm curious about the involvement of hardware vendors to support the new features coming in Windows 8.

Windows 7 was launched with support for touch input, but it never really gained traction due to lack of a compelling tablet device - the Touchsmarts were a nice device, but were primarily for kiosks, rather than daily usage.

Compare Windows 7 to the WP7 launches - which have been done with device announcements involving hardware vendors - and it gives me hope that the launch can be done in a more "complete" fashion. 

And I want to see more presentations from MSFT about Windows 8 using touch - drive the presentations from a tablet, demonstrate how the new UI supports touch, and compel me to put it everywhere.
