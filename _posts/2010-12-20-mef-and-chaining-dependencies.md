--- 
layout: post
title: MEF and Chaining Dependencies
permalink: mef-and-chaining-dependencies.html
description: A quick blog example of how to use contracts within MEF to handle complex dependency chains
funnelweb_id: 6
date: 2010-12-20 14:00:00 +11:00
tags: "mef composition dependencies .net "
comments: true
---
A [question][1] came up on the MEF discussion board recently (today?) about how to handle a complex graph of dependencies. Although it was "solved" - and I suspect it was a case of missing the required assembly, going by what info was at hand - it still prompted me to dig into how one can go beyond the basics.

Scenario
-----------------------------
Imagine you have an application that calls off different services to execute tasks. Rather than hard-coding the services into the application, these can be defined as parts which are composed at runtime using MEF.

But the relationship between the application and the services is not straightforward, which gives a dependency graph similar to the below image:

<center><img src="http://brendanforster.com/get/images/DependencyGraph.png" height="500"  /></center>

What should we do now?

As MEF uses the concept of a "contract" to resolve the &#91;Import&#92; and &#91;Export&#92; statements sprinkled within an application, this ultimately comes down to two similar approaches.


Using Contract Names
-----------------------------

If the Proxy and Service implementations are equivalent - so we can avoid using distinct interfaces for behaviour which is identical - then we can use the same interface and specify a different contract for each extensibiity point defined in the application.

    public class ConsumingApplication
    {
        &#91;ImportMany("Contoso.Application", typeof(IServiceProxy))&#92;
        public IEnumerable&lt;IServiceProxy&gt; Services { get; set; }
        
        // implementation here
    }

And our simple client can use the corresponding &#91;Export&#92; statement.

    &#91;Export("Contoso.Application", typeof(IServiceProxy))&#92;
    public class StandaloneProxy : IServiceProxy
    {
        // implementation here 
    }

Our complex dependency has a bit more code, but it can be broken down into two main features:

The contract which it satisfies - **Contoso.Application** and **IServiceProxy**

The contract which it requires - **Contoso.External** and **IServiceProxy**
    
    &#91;Export("Contoso.Application", typeof(IServiceProxy))&#92;
    public class ActualProxy : IServiceProxy
    {
        &#91;ImportMany("Contoso.External")&#92;
        public IEnumerable&lt;IServiceProxy&gt; Services { get; set; }

        // implementation here
    }


So while reusing the same interface, we can specify *how* the parts relate.


Using Contract Types
-----------------------------

If the behaviour of the proxy and the actual service are different, then we can just use the types to represent the contract.

    public class ConsumingApplication
    {
        &#91;ImportMany(typeof(IServiceProxy))&#92;
        public IEnumerable&lt;IServiceProxy&gt; Services { get; set; }

        // implementation here
    }

The exported contract becomes:

    &#91;Export(typeof(IServiceProxy))&#92;
    public class StandaloneProxy : IServiceProxy
    {
        // implementation here
    }

And our complex part still has two contracts:

The contract which it satisfies - the **IServiceProxy** contract.

The contract which it requires - the **IService** contract (implicit due to the awesomeness of ImportMany)

    &#91;Export(typeof(IServiceProxy))&#92;
    public class ActualProxy : IServiceProxy
    {
        &#91;ImportMany&#92;
        public IEnumerable&lt;IService&gt; Services { get; set; }

        // implementation here
    }

No more magic strings, while still being able to declare


And finally, InheritedExport
-----------------------------

To really simplify the contracts, you can use &#91;InheritedExport&#92; on the interface. This declares to MEF that all types which implement the interface should be used as exported parts, using the interface type as the contract.

So I annotate both interfaces:

    &#91;InheritedExport&#92;
    public interface IServiceProxy
    {
        // code here
    }

    &#91;InheritedExport&#92;
    public interface IService
    {
        // code here
    }

and can eliminate all other &#91;Export&#92; attributes from the codebase:

    public class StandaloneProxy : IServiceProxy
    {
        // implementation here
    }

    public class ActualProxy : IServiceProxy
    {
        &#91;ImportMany&#92;
        public IEnumerable&lt;IService&gt; Services { get; set; }

        // implementation here
    }



Thoughts?


  [1]: http://mef.codeplex.com/Thread/View

