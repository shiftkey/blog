--- 
layout: post
title: Arguments about Project Structure
permalink: /arguments-about-project-structure.html
description: Putting pen to paper about some back and forth I've been having over IM about the 'right' way to set up projects...
funnelweb_id: 11
date: 2011-02-23 14:00:00 +11:00
tags: "projects"
comments: true
---

Whenever it comes time to kick off a new project, how do you structure it?

Given a greenfields situation - or even one of my side projects - I go for this layout:

 - build
 - lib
 - src
   - samples
   - Project.ModuleA
   - Project.ModuleB
   - Project.Shell
   - Project.sln
 - tools

And what do those these folders represent?

**build** - scripts for building and deploying the application. As soon as the application is required to be deployed to different environments, this should be scripted and added to source control.

**lib** - dependencies required by the application. I generally group the dependent assemblies if required, but will generally drop the dll-xml combination into the root folder.

**samples** - once the main solution gets beyond a specific size, it may be beneficial to separate the sample code out rather than compiling it within the main build.

**src** - there be code.

**tools** - dependencies required to build the application. This does not mean including every tool required to set up the developer baseline, but any special tools used during the build process

For example, these would not belong:

 - Visual Studio
 - .NET Framework

But I'd happily include these tools:

 - FxCop
 - NCover
 - MSBuild Community Tasks

as not all developers would have them installed on their machines.

## Why this structure?

**Folder Names** 

Remember the days of 8.3 filesystems? I do. But thankfully this isn't about that.  

This structure also borrows from Unix conventions for arranging their codebases. I don't like how the necessary make files are hosted at the root.

As we're using Mercurial, we don't need to worry about using trunks or tags in the structure.

**Experience** 

When I challenged [@aeoth's][1] project structure for the next version of MahTweets, he wanted to make it so that a developer with little experience in .NET (or programming) could download the source and try it out.

I'd argue the best introduction to a codebase is two things:

 - a README file to provide some notes about the application
 - a batch file or script to run the application and execute tests
 - sample projects to complement the source
 
**The build is important**

We had various pain points with the last version of MahTweets around managing loosely-coupled modules under development, and then building a signed ClickOnce installer with a custom script.

It ended up being a painful few nights bashing against MSBuild (have you ever tried to use SignFile manually?), but the effort burnt reminds me everytime I come across a new team or project to ask two simple questions:

- how can someone build and run the application with limited knowledge of the codebase?
- how can someone test the application with limited knowledge of the codebase?

If that process is known and documented, it highlights all the quirks with getting the application out. If it isn't documented, then typically you need to find the right person at the right time...

Putting the build components separate, but easily visible, makes everyone's life easier.

**Habit**

And lastly, this is my personal opinion. Having spent a lot of time playing around with Linux OSS in the past, I keep coming back to that style of structure when setting up my own projects. Seeing things like uppercase folder names at the root just feel odd.

[1]: http://twitter.com/aeoth
