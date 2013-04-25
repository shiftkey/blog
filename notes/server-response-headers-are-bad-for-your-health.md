---
layout: post
title: Custom IIS headers are a security risk - why are they on by default?
date: 2013-04-25 16:00:00 +10:00
---

I'm guiding another customer through a pentest review soon for an upcoming release, and of course we have to switch off all the headers that IIS and ASP.NET serve up to the user.

In particuar:

 - Server (from IIS)
 - X-Powered-By (from IIS)
 - X-AspNet-Version (from ASP.NET)
 - X-AspNetMvc-Version (from ASP.NET MVC)

It's not a hard process, but you have to do three different things to switch them all off:

 - Server - add an ASP.NET Module to wireup an event handler for the PreSendRequestHeaders 
 - X-Powered-By - configure IIS or web.config change
 - X-AspNet-Version - web.config change
 - X-AspNetMvc-Version - code change

And of course I had to stop myself midway through explaining these steps and ask "Why are these even enabled by default?"

## Let's solve this with NuGet

So I can picture a hypothetical NuGet package which will do all this:

 - drop in a handler under the root of the project which solves 1
 - add in a web config transform to apply 1, 2 and 3.
 - use WebActivator and wireup a module to set the `MvcHandler` on startup

 
