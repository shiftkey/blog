--- 
layout: post
title: Hello World
permalink: /hello-world.html
description: Just a quick introductory post to kick things off.
date: 2010-09-23 10:50:44 +10:00
comments: false
---
Starting off this blog with a simple post. More styling to come during the coming days.

**Side note:** here's the Factorial function in F#:

{% highlight fsharp %}
let rec factorial n =
match n with
| 0 -> 1
| _ -> n * factorial (n - 1)
{% endhighlight %}
