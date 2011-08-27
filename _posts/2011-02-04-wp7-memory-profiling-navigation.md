--- 
layout: post
title: WP7 - Memory Profiling Adventures - Navigation (Updated)
permalink: wp7-memory-profiling-navigation
description: The joys of a new platform... documenting a strange behaviour found when profiling a WP7 app. Somewhat resolved...
funnelweb_id: 8
date: 2011-02-04 14:00:00 +11:00
tags: "wp7 memory profiling "
comments: true
---
In the course of wrapping up a SL-based WP7 application recently, I stumbled across a significant hurdle with memory consumption on the device...

Updated
-------------

After going back and forth with local Windows Phone guru [Nick Randolph][6] about the issue, and he [blogged][7] [about][8] the behaviour in more detail, we came to the conclusion that the garbage collection was not being triggered automatically. That's not necessarily a bad thing (see the [conditions for triggering a garbage collection][8] here) but is a concern for large WP7 applications.

The workaround I devised for this is to trigger a GC.Collect() after a number of page navigations. I would only add this to an application when absolutely necessary. The implementation of this I'll leave as an exercise to the reader.

Side note: I've seen various samples floating around which will use a timer to invoke a garbage collection call. Ignoring the use of timers on the device (which will drain the battery), a garbage collection call at an arbitrary time will likely impact on the user experience. Be smart about it, if you need to work this into an application.

Read on for the rest of the saga...


Before We Begin...
-----------------------------
One of the requirements a WP7 application needs to satisfy is around memory consumption

<h3>5.2.5 Memory Consumption</h3>

*An application must not exceed 90 MB of RAM usage, except on devices that have more than 256 MB of memory. You can use the **DeviceExtendedProperties** class to query the amount of memory that is available on the device and modify the application behavior at runtime to take advantage of additional memory. For more information, see the DeviceExtendedProperties class in MSDN.*

*Note:*

*The DeviceTotalMemory value returned by **DeviceExtendedProperties** indicates the physical RAM size in bytes. This value is less than the actual amount of device memory. For an application to pass certification, Microsoft recommends that the value returned by ApplicationPeakMemoryUsage is less than 90 MB when the DeviceTotalMemory is less than or equal to 256 MB*

Source [Microsoft][1] 

90 MB sounds like a lot of space - and yes, it is, when one remembers the era of 1.44MB diskettes (or earlier) you can't help but think that perhaps we are spoiled - but what can you do with that amount of memory?

**Note** - Disregard the "devices with > 256MB" exception mentioned, as I want to see how we can optimise memory usage on SL without sacrificing features.

How Do I Work Out My Memory Usage?
-----------------------------

As mentioned above, the **DeviceExtendedProperties** class contains a lot of runtime information about the application.

I drop this method into the App.xaml.cs class so that I can get statistics at any point of the application's lifecycle.

	public static void GetMemoryUsage(string task)
	{
		var number = (long)DeviceExtendedProperties.GetValue("ApplicationCurrentMemoryUsage");
		Debug.WriteLine("{0} - ApplicationCurrentMemoryUsage: {1}", task, number);
		number = (long)DeviceExtendedProperties.GetValue("ApplicationPeakMemoryUsage");
		Debug.WriteLine("{0} - ApplicationPeakMemoryUsage: {1}", task, number);

		Debug.WriteLine("");
	}

Oh, and don't forget the namespace

	using Microsoft.Phone.Info;

This allows parts of the application to log diagnostics, like:

	private void MainPageLoaded(object sender, RoutedEventArgs e)
	{
		if (!App.ViewModel.IsDataLoaded)
			App.ViewModel.LoadData();

		App.GetMemoryUsage("Main - Loaded");

	}

and see a message like in the Output Window:

	Main - Loaded - ApplicationCurrentMemoryUsage: 39870464
	Main - Loaded - ApplicationPeakMemoryUsage: 39899136


And now things get interesting...
-----------------------------

Testing out a simple application - two screens, both use the Panorama Control and independent ViewModels which display a "large" list of items (270-ish items, but text only).

Selecting an item in the main screen will navigate to the second screen. Pressing back will return the application to the main screen.

The code is [here][2] and the sample output can be seen on [Gist][3] 

Graphing the memory at each step, the graph looks like this:

<center><a href="http://brendanforster.com/files/images/breakdown.png"><img src="http://brendanforster.com/files/images/breakdown.png" width="800" /></a></center>

But why is the memory footprint larger (by almost 10 MB) on returning to the main screen?

**Note:** Removing the Panorama Control did not change this behaviour - it just made the numbers smaller (a 5MB difference rather than 10MB). Just a sign that making screens leaner will certainly assist with reducing the overall footprint, but not the answer I was looking for.

Repeating the scenario a few times, and the behaviour is the same.

<center>
<a href="http://brendanforster.com/files/images/pattern.png"><img src="http://brendanforster.com/files/images/pattern.png" width="800" /></a></center>

Puzzling...

And the adventure begins
-----------------------------

The underlying _why_ is what I want to understand more. Even with this simple application - which is displaying a large list of items - the size of the application is already close to the 90MB limit.

I've only been able to throw a couple of hours of spare time at this so far, but here's some notes from my investigation currently:

 - Tested this with the [new emulator and SDK changes][4]. No change to the behaviour.

 - Haven't found any memory profiling tools for SL & WP7 - if anyone has stuff in the works, I'd love to try them out. [EQUATEC][5] make a profiler for CPU performance, which works wonderfully from my limited testing.

 - Aggressive garbage collection helped somewhat, but this approach makes me feel unclean. Using timers on the device to trigger a GC Collect is bad for battery performance, and the demo above shows that memory usage can spike between events for a PhoneApplicationPage. 

 - Paging data from isolated storage could be worth attempting, but I don't think this is a temporary fix - as the application would load the full file, select a subset of the data, and then dispose the file. Chunking data in isolated storage would increase complexity.

 - Avoiding the use of navigation - and rolling some custom controls to support transitions instead - is the method that needs most work, but gives more control back to the application.


  [1]:http://go.microsoft.com/?linkid=9730556
  [2]:http://brendanforster.com/get/panoramasample.zip
  [3]:https://gist.github.com/812178
  [4]:http://windowsteamblog.com/windows_phone/b/wpdev/archive/2011/02/04/windows-phone-developer-tools-january-update.aspx
  [5]:http://eqatec.com/Profiler/Overview.aspx
  [6]:http://nicksnettravels.builttoroam.com/
  [7]:http://nicksnettravels.builttoroam.com/blogengine/post/2011/02/10/Windows-Phone-7-Navigation-Memory-Usage.aspx
  [8]:http://nicksnettravels.builttoroam.com/blogengine/post/2011/02/10/Windows-Phone-7-Navigation-Memory-Usage-Just-Got-Scary.aspx
  [9]:http://msdn.microsoft.com/en-us/library/ee787088.aspx#conditions_for_a_garbage_collection
