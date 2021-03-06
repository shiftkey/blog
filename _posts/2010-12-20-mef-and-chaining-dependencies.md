---
layout: post
title: MEF and Chaining Dependencies
permalink: /mef-and-chaining-dependencies.html
description: A quick blog example of how to use contracts within MEF to handle complex dependency chains
date: 2010-12-20 14:00:00 +11:00
tags: "mef composition .net "
comments: true
---
A [question][1] came up on the MEF discussion board recently (today?) about how to handle a complex graph of dependencies. Although it was "solved" - and I suspect it was a case of missing the required assembly, going by what info was at hand - it still prompted me to dig into how one can go beyond the basics.

## Scenario

Imagine you have an application that calls off different services to execute tasks. Rather than hard-coding the services into the application, these can be defined as parts which are composed at runtime using MEF.

But the relationship between the application and the services is not straightforward, which gives a dependency graph similar to the below image:

<center><img src="img/posts/DependencyGraph.png" height="500"  /></center>

What should we do now?

As MEF uses the concept of a "contract" to resolve the `[Import]` and `[Export]` statements sprinkled within an application, this ultimately comes down to two similar approaches.


## Using Contract Names

If the Proxy and Service implementations are equivalent - so we can avoid using distinct interfaces for behaviour which is identical - then we can use the same interface and specify a different contract for each extensibiity point defined in the application.

{% highlight csharp %}
public class ConsumingApplication
{
    [ImportMany("Contoso.Application", typeof(IServiceProxy))]
    public IEnumerable<IServiceProxy> Services { get; set; }

    // implementation here
}
{% endhighlight %}

And our simple client can use the corresponding [Export] statement.

{% highlight csharp %}
[Export("Contoso.Application", typeof(IServiceProxy))]
public class StandaloneProxy : IServiceProxy
{
    // implementation here
}
{% endhighlight %}

Our complex dependency has a bit more code, but it can be broken down into two main features:

 - The contract which it satisfies - **Contoso.Application** and **IServiceProxy**
 - The contract which it requires - **Contoso.External** and **IServiceProxy**

Which looks like this:

{% highlight csharp %}
[Export("Contoso.Application", typeof(IServiceProxy))]
public class ActualProxy : IServiceProxy
{
    [ImportMany("Contoso.External")]
    public IEnumerable<IServiceProxy> Services { get; set; }

    // implementation here
}
{% endhighlight %}

So while reusing the same interface, we can specify *how* the parts relate.

## Using Contract Types

If the behaviour of the proxy and the actual service are different, then we can just use the types to represent the contract.

{% highlight csharp %}
public class ConsumingApplication
{
    [ImportMany(typeof(IServiceProxy))]
    public IEnumerable<IServiceProxy> Services { get; set; }

    // implementation here
}
{% endhighlight %}

The exported contract becomes:

{% highlight csharp %}
[Export(typeof(IServiceProxy))]
public class StandaloneProxy : IServiceProxy
{
    // implementation here
}
{% endhighlight %}

And our complex part still has two contracts:

 - The contract which it satisfies - the **IServiceProxy** contract.

 - The contract which it requires - the **IService** contract (implicit due to the awesomeness of ImportMany)

Which looks like this:

{% highlight csharp %}
[Export(typeof(IServiceProxy))]
public class ActualProxy : IServiceProxy
{
    [ImportMany]
    public IEnumerable<IService> Services { get; set; }

    // implementation here
}
{% endhighlight %}

## And finally, InheritedExport

To really simplify the contracts, you can decorate the interface with the `[InheritedExport]` attribute. This declares to MEF that all types which implement the interface should be used as exported parts, using the interface type as the contract.

So I annotate both interfaces:

{% highlight csharp %}
[InheritedExport]
public interface IServiceProxy
{
    // code here
}

[InheritedExport]
public interface IService
{
    // code here
}
{% endhighlight %}

and can eliminate all other [Export] attributes from the codebase:

{% highlight csharp %}
public class StandaloneProxy : IServiceProxy
{
    // implementation here
}

public class ActualProxy : IServiceProxy
{
    [ImportMany]
    public IEnumerable<IService> Services { get; set; }

    // implementation here
}
{% endhighlight %}

Thoughts?


  [1]: http://mef.codeplex.com/Thread/View
