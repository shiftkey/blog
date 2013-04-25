---
layout: post
title: Why enable custom headers if they're a security risk?
date: 2013-04-25 16:00:00 +10:00
---

Another customer is going through a pentest soon, and of course we have to switch off all the headers that IIS and ASP.NET serve up.

 - Server
 - X-Powered-By
 - X-AspNet-Version

The worst part of all this is how there's three different spots to remove this:

 - Server - you need an ASP.NET Module to wireup an event handler for the PreSendRequestHeaders 
 - X-Powered-By - defined in IIS
 - X-AspNet-Version - web.config setting

 Ugh