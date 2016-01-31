---
layout: post
title: The Zen Of Reporting A Bug
date: 2013-11-29 17:30:00 -7:00
---

I've been involved with a bunch of open source projects in the past - as a
maintainer, a contributor and a consumer - as well as more traditional projects,
and I think every bug report can be organised into one of several buckets.  

These are sorted in order of quality (from least to most helpful).
If you've ever submitted a bug report, you can probably guess which of the
buckets your feedback has fallen into.

I'm mostly writing this up so I can point others to it so they can understand
what makes a good bug report. I'm sure other people have done something similar
elsewhere. Good on them.

## Level 0
### "It doesn't work"

It's okay to get angry sometimes. We all do it - especially when it's your first
time using a library or framework and it doesn't quite work as advertised.

But don't think it's helpful. Or productive. Look, here's some clown doing just
that:

**TODO: tweet of mine**

So mash the keyboard and send those sweet, sweet words of rage into the aether.
Feel better?

## Level 1
### "I tried to do something and it didn't work!"

Have you taken a deep breath and counted to ten? Great, let's continue.

If you can share some details around your scenario and how you got here, it'll
help everyone else understand:

 - "I was trying to install this into a XYZ app",
 - "I was trying to use ABC feature",
 - "It doesn't run on blah-blah OS",

This helps everyone else understand a bit more about the scenario you're trying
to work with, but particularly in two ways:

 - it might be a scenario that someone is familiar with, in which case there's
   probably another discussion elsewhere which might have a workaround or
   solution
 - it might be a scenario so out of left field that no-one was expecting it, in
   which case they can also have a look at recreating

So before you open an issue, do a search to see if someone else has found this.
Google is great for this (although it can tricky to use the right combination
of search terms if you're unfamiliar with the verbiage). Or even StackOverflow.

## Level 2
### "I got this error message"

No luck there? Ok, I guess we need to drill down into the details and understand
more of the story.

Can you step through the details of what lead you to finding this issue? A list
of instructions like this helps others understand more:

 - I created a new XYZ project with version blah-blah of some web framework
 - I've got {this, that and the other} libraries installed
 - I added version ABC of your library to the project
 - I tried this code and it did `foo` instead of `bar`

This helps identify possible interactions between components that might have
been missed by contributors to the project. After all, they're only humans (as
far as we know)

## Level 3
### "This code snippet doesn't work for me"

If we're *still* struggling at this point to identify the issue, then the only
real option is a code sample. This is often hard for people to put together
because it requires them to modify their codebase and remove sensitive details -
intellectual property, things that shouldn't be shared with the world, etc.

If you can do this it's a great benefit to the contributors, as they:

 - have a working demo that highlights the issue
 - can plug this sample into their existing test suite
 - can turn it into a regression test so the issue remains resolved

Sometimes maintainers are happy to do this privately rather than publicly, see
for example how [Walmart and the NodeJS core team worked together to find a
memory leak](http://www.joyent.com/blog/walmart-node-js-memory-leak). If there's
a specific scenario you'd like to investigate but are unable to do it publicly,
reach out to them to see if there are other avenues.

## Level 4
### "I have this demo project"


## Level 5
### "I found this problem and doing this thing fixed it"

## Level 6
### "I found this problem and here's a patch which fixes it"
