--- 
layout: post
title: "Soapbox: INotifyPropertyChanged - Stop the Madness"
permalink: inotifypropertychanged-stop-the-madness.html
description: Just wanted to recap why I see the argument over INotifyPropertyChanged usage as absurd.
funnelweb_id: 16
date: 2011-06-18 14:00:00 +10:00
tags: "wpf silverlight wp7 soapbox"
comments: true
---
Its time to stop with this madness.

Apologies again to [Ian][1] as I picked on him unnecessarily when I read yet another "Let's make OnPropertyChanged compile safe" [blog post][2] yesterday.

I don't have an issue with the approach, but I had an issue with the bigger picture - how little had changed for XAML developers in this regard. Keep in mind that lambdas were first made available in C# 3.0 - which itself was made available in 2007, with .NET 3.5.

I've been summoned into this debate [before][3] (and was assumed to be a "cool kid") so I thought I'd put down some thoughts on the issue, and what I think needs to change:

## Stop writing plumbing code

Every time you write logic in the setter of a property, an angel disappoints her family by taking up stripping.

There have been compelling reasons to do so. After dealing with the resulting pain, I've explored other options to take all those needs away. So let's break it down:

To start off with the *worst* case scenario, we have:

    private string _someProperty;
    public string SomeProperty
	{
		get { return _someProperty; }
		set 
		{ 
			_someProperty = value;
			OnPropertyChanged("SomeProperty");
		}
	}

### Make it refactor-friendly - let's use a lambda instead!

Yes, this is better than magic strings - that's about it. Don't you get that sinking feeling when adding a new property to the viewmodel, and the code inside the setter looks almost identical to all the others?

So let's change the property to look like:

    private string _someProperty;
    public string SomeProperty
	{
		get { return _someProperty; }
		set 
		{ 
			_someProperty = value;
			OnPropertyChanged(() => SomeProperty);
		}
	}

For an example implementation that accepts lambda statements, [this Stackoverflow answer][4] is a good starting point.

### I only want to raise the change when the backing value actually changes!

"Wait," the audience exlaims in shock, "you're going to raise the event each time now." The author relents, and adds some code to end the pain for the audience:

    private string _someProperty;
    public string SomeProperty
	{
		get { return _someProperty; }
		set 
		{ 
			if (_someProperty == value)
				return;
				
			_someProperty = value;
			OnPropertyChanged(() => SomeProperty);
		}
	}

I'd better ensure this is defined in all the setters, and that the right backing field is used in each case. I'd look pretty silly if I'd used the wrong field, like this:

	// elsewhere in the codebase
    private string _someOtherProperty;

	// ...

    private string _someProperty;
    public string SomeProperty
	{
		get { return _someProperty; }
		set 
		{ 
			if (_someOtherProperty == value)
				return;
				
			_someProperty = value;
			OnPropertyChanged(() => SomeProperty);
		}
	}
	
so I'd better do it real carefully...

### We need caching now!

Really? That's what comes to mind next? You crazy developers.

Fine, let's add a dictionary to capture the event arguments, instead of recreating them each time (adapted from this [blog post][5]):

    public class ViewModelBase
    {
        protected void OnPropertyChanged(Expression<Func<object>> lambda)
        {
            // Go read Paul (and especially Miguel's comment) about this [here][6]. I'll wait...
        }
		
        private IDictionary<string, PropertyChangedEventArgs> _handlers = new Dictionary<string, PropertyChangedEventArgs>		
		
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChangedEventArgs args;
		
            if (!_handlers.ContainsKey(propertyName))
            {
                _handlers.Add(propertyName, new PropertyChangedEventArgs(propertyName));
            }
			
            args = _handlers[propertyName];
			
            PropertyChanged(this, args);
        }
    }

Have we saved much? Perhaps. Perhaps not...
 
### Wait, what about cross-thread issues? I do a lot on the background thread!

Ah yes. Have you ever been bitten by this one - a background thread updates a property, which triggers the PropertyChanged event, which asplodes because the UI can only be updated from the main thread? 
 
## Stop. Put down the keyboard for a minute.

See how quickly all these features around INotifyPropertyChanged can spiral out of control? You've worked out the code and classes necessary to solve a common problem, but some overhead remains for writing boilerplate code everywhere the solution is required. And while it is a manual process, it is prone to human error.

Go back and read that last sentence again. Did something click about what you've been doing all along with INotifyPropertyChanged?

![Huzzah!][7]

## A what?

INotifyPropertyChanged is a very specialised example of a cross-cutting concern.

We use INotifyPropertyChanged in many places when doing XAML-based applications - as it is critical when databinding POCO objects without requiring the use of DependencyProperty instances. Although we spent a lot of time optimising the behaviour of invoking INotifyPropertyChanged, we didn't improve **how** this code is used - we're still copying-and-pasting the same code around, and having to make manual changes to each instance to suit the property.

We need the ability to apply the INotifyPropertyChanged behaviour in an automatic way. Of course, there are various tradeoffs to consider - which I'll outline from my experiences.

## What Next?

I need to wrap this post up before it becomes even longer, so until my next post - where I'll discuss how AOP flips all this discussion on its ear - readers can get ahead by reading these links:

**Sacha Barber - [Aspect Examples (INotifyPropertyChanged via Aspects)][8]**

[Philip Laureano][9] linked me this yesterday. A large read, but lots of demo code for people who want to see something more concrete.

**[NotifyPropertyWeaver][10] - a .NET library for weaving INotifyPropertyChanged code into IL**

This is my library of choice for automating INotifyPropertyChanged usage. I definitely owe [Simon][11] a beer (or drink of choice) next time we cross paths - its been a joy to use.


  [1]: http://twitter.com/kiwipom
  [2]: http://xaml.geek.nz/binding/5
  [3]: http://www.mail-archive.com/ozdotnet@ozdotnet.com/msg03903.html
  [4]: http://stackoverflow.com/questions/141370/inotifypropertychanged-property-name-hardcode-vs-reflection/1209104#1209104
  [5]: http://www.paulstovell.com/strong-property-names
  [6]: /img/posts/10-gallon-cowboy-hat.png
  [7]: /img/posts/Achievement.jpg
  [8]: http://www.codeproject.com/KB/library/Aspects.aspx
  [9]: http://twitter.com/philiplaureano
  [10]: http://code.google.com/p/notifypropertyweaver/
  [11]: http://twitter.com/simoncropp
