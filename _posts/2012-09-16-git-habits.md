--- 
layout: post
title: My Git Habits
permalink: /notes/my-git-habits.html
description: Someone asked me to write down some notes about my git habits. I'm putting them up here as well for anyone else who cares.
date: 2012-09-16 17:00:00 +10:30
icon: /img/main/soapbox.jpg
comments: true
---
 
First up, a disclaimer: **This is just one person's opinion and should be treated as such.** 

If you workflow is similar, that's great. If you workflow is radically different, that's great too. With things like git its very easy to have different workflows, so I'll just be speaking from my experiences here.

### Introduction

Generally speaking, my git flow is based off the [documentation](https://github.com/NancyFx/Nancy/wiki/Git-Workflow) for contributors to the NancyFx project. When working on features, this is my high-level flow:

 1. Create a local branch for the feature
 2. Work on your feature and get it reviewed -- you do code reviews, right?
 3. Merge the changes into master
 4. Push the changes up to the remote repository

How does that look from the comamnd line?

 - git checkout -b ReallyCoolFeature master
 - ... stuff gets done ...
 - git add -u . -- add all removes and modifies to the staging area
 - git add .    -- add new files to the staging area
 - git commit -m "#1234 implemented" -- associating commits with work items is awesomely helpful
 - git checkout master
 - git pull origin/master
 - git merge ReallyCoolFeature
 - git push origin master

**Note:** Yeah, I like to be explicit with my remotes and branch names in these commands. Haters gonna hate.

But that's all fairly straight-forward and not really leveraging the [new states of mind](http://think-like-a-git.net/sections/git-makes-more-sense-when-you-understand-x/example-4-lsd-and-chainsaws.html) that git makes possible.

### Rebase all the things

Where git truly comes into its own is with rebasing. For those who aren't familiar with it, rebasing allows you to change the history of a branch. This is generally considered very bad&#0153; to do with public repositories but when you use it only locally it gives you so much control over everything.

For example, have you ever:

 - used a branch for multiple, disparate tasks that you wish you could reorder for readability?
 - accidentally forgot to save a file and had to spread a task over multiple commits as a result?
 - wanted to update an old branch to the latest changes and avoid merge conflicts?
 - wanted to split out a branch into multiple branches and process them separately?

If you consider a branch to be a chain of commits - with a parent commit representing the creation point of the branch - then rebasing is the operation to:

 - change the creation point of a branch
 - change the order of the commits in a branch
 - change the commits in a branch - squash commits together
 - remove commits from a branch

At this point you are probably thinking "Oh man, I'm going to nuke my branch and lose all my work" but if you look more closely at what the rebase does, you'll find that its a lot safer than you think.

A rebase operation will

 - set the repository to the new creation point
 - create a temporary branch just for this rebase operation
 - apply the commits one by one to ensure they apply cleanly
 - update the pointers for the branch and remove the temporary branch
 - set the repository to the last commit of the new branch

When I say "ensure the commits apply cleanly" here, I indicate that git will ensure that additions and subtractions to each file make sense. If they don't (for example, the file has changed significantly enough), it will pause and ask the user to manually confirm the commit.

At any point during a rebase that requires user input, you can abort and git will roll back to the state it was in before the rebase operation started.

### Speak English, Brendan!

So I got side-tracked a bit just then. Apologies.

So what do I use rebasing for?

 - *reordering* - if I do a bit of code cleanup during my work, that remains separate from the current task and can be put before/after when reviewing code
 - *squashing* - generally speaking, your commits should be granular enough to be easy to follow. But sometimes things go too far and you want to bring related commits together (e.g. missed deleting a file from the previous commit)
 - *splitting* - if you've got a complex branch you could split it up into multiple branches and integrate them in gradually.

All of this is possible by using interactive rebase - before it kicks off the operation, it displays the commits available and allows you to specify the operations to perform.

**Note:** There's two minor differences when you squash commits together. One operation, `fixup`, is intended to merge a commit without including the commit message. The other, `squash`, will bring the commit message across and allow you to edit the commit message after the squash.

### Merging is overrated anyway

Yes, that might be a controversial thing to say at this point. Merges are considered important to indicate when two branches have been brought together. But I submit to you, the jury of the internet - do we really need it? I'm not advocating abandoning merges at all - they have a purpose, which is to indicate changes additional to the branch being merged in. 

If I can rebase a branch on top of the current master, I've just avoided the need for a merge commit completely (it becomes a fast-forward merge and the pointers are moved forward). I can then push and get on with the next task.

I guess this comes back to how you use branches. Git works excellently when you create a branch for a task, integrate the code into master, and delete the branch once its reached the end of its useful life. 

Not everyone can work that way (that might be a rant for another day), but I see this a discipline issue rather than a pro/con of the tool itself.

### My Opinionated Git Flow

So with a slight tweak to step 3, my flow becomes:

 1. Create a local branch for the feature
 2. Work on your feature and get it reviewed -- you do code reviews, right?
 3. Rebase the branch on master
 4. Push the changes up to the remote repository

How does that look from the comamnd line?

 - git checkout -b ReallyCoolFeature master
 - ... stuff gets done ...
 - git add -u . -- add all removes and modifies to the staging area
 - git add .    -- add new files to the staging area
 - git commit -m "#1234 implemented" -- associating commits with work items is awesomely helpful
 - git checkout master
 - git pull origin/master master
 - git rebase master ReallyCoolFeature
 - git checkout master
 - git merge ReallyCoolFeature --ff-only
 - git push origin master

Combine that with some hot git alias action (this is getting fairly long as-is), you can strip away much of those commands into a simple "sync" step which you run against the branch you are working on.

### What's next?

I could go on about using `reset` and `cherry-pick` commands and head further down the git rabbit hole, but I think the next posts should cover these things:

 - `git alias` - seriously, this is like crack for scripters
 - a general rant about discipline when managing commits - git has corrupted my brain, and I've found myself applying concepts to situations where I have used other VCSes (even TFS, not using git-tfs or tf-git)

