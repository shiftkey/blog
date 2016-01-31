---
layout: post
title: Custom server headers - bad for your health?
date: 2013-05-04 16:00:00 +10:00
description: Wherein I jump up and down about something seemingly silly
permalink: /blog/custom-server-headers-bad-for-your-health.html
comments: true
---

I just finished another project with a customer which involved a pentest (penetration testing) review for their upcoming launch. And as usual, this involves hiding a bunch of headers that IIS and ASP.NET serve up on each response.

In particuar:

 - Server (from IIS)
 - X-Powered-By (from IIS)
 - X-AspNet-Version (from ASP.NET)
 - X-AspNetMvc-Version (from ASP.NET MVC)

Why? Because sending these headers in your response exposes information about your server to clients (including the bad guys). [Troy Hunt](http://www.troyhunt.com/2012/02/shhh-dont-let-your-response-headers.html) explains it in more detail but our approaches differ slightly:

 - I've just focused on the ASP.NET stack
 - this approach doesn't require any changes to IIS
 - I don't care about IIS 6 (it shipped with Windows Server 2003, so that'll be 10 years soon!)

## NuGet all the pain away

So I was going to write a NuGet package to solve this problem but I was then pointed to this package from David Duffett - [Dinheiro.RemoveUnnecessaryHeaders](https://github.com/davidduffett/Dinheiro/tree/master/Dinheiro.RemoveUnnecessaryHeaders). Thanks for saving me the time, David!

So go grab it from NuGet:

    PM> Install-Package Dinheiro.RemoveUnnecessaryHeaders

You can do this by hand if you want - in fact, I'll explain the package behaviour here.

First, it applies a config transform to remove the `X-Powered-By` and `X-AspNet-Version` headers:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.web>
    <httpRuntime enableVersionHeader="false" />
  </system.web>
  <system.webServer>
    <httpProtocol>
      <customHeaders>
        <remove name="X-Powered-By" />
      </customHeaders>
    </httpProtocol>
  </system.webServer>
</configuration>
{% endhighlight %}

Next, we use `WebActivator` to hook into the `PreApplicationStart` event to run some custom behaviour:

{% highlight csharp %}
[assembly: WebActivator.PreApplicationStartMethod(typeof(MyWebApplication.App_Start.RemoveUnnecessaryHeaders), "Start")]
{% endhighlight %}

This method takes care of two things. The first is disabling the `X-AspNetMvc-Version` header, and then registering a module to remove the `Server` header.

{% highlight csharp %}
public static class RemoveUnnecessaryHeaders
{
    public static void Start()
    {
        DynamicModuleUtility.RegisterModule(typeof(RemoveUnnecessaryHeadersModule));
        MvcHandler.DisableMvcResponseHeader = true;
    }
}
{% endhighlight %}

And there's an important note about this code - it's only supported for IIS7+. Just a heads up.

{% highlight csharp %}
public class RemoveUnnecessaryHeadersModule : IHttpModule
{
    public void Init(HttpApplication context)
    {
        // This only works if running in IIS7+ Integrated Pipeline mode
        if (!HttpRuntime.UsingIntegratedPipeline) return;

        context.PreSendRequestHeaders += (sender, e) =>
        {
            var app = sender as HttpApplication;
            if (app != null && app.Context != null)
            {
                app.Context.Response.Headers.Remove("Server");
            }
        };
    }

    public void Dispose() { }
}
{% endhighlight %}

That `PreSendRequestHeaders` event is the last opportunity ASP.NET gets to intercept the response (including reading headers set by IIS) before it gets sent to the client.

## Defaults are good - except when they're not

Just about all of the teams I've worked with have had this requirement as part of their go-live checklist (or raised by a security review) which made me think...

*Why aren't these headers disabled by default?*

*And why does it require changes in so many different places in IIS and ASP.NET?*

## A footnote on X- Headers

If this is the first you are reading about this issue, HTTP headers which are prefixed by X- are custom headers which are not part of the HTTP spec. It allows servers, frameworks and applications to include custom metadata in HTTP requests and responses.

My favourite example of this is Twitter's Rate Limiting API, which sends custom headers with each API call that an application makes:

    X-RateLimit-Limit: 350
    X-RateLimit-Remaining: 350
    X-RateLimit-Reset: 1277485629

As a consumer of Twitter's API, my application would need to look for these headers and understand the values.

Recently [Cristian](http://cprieto.com) pointed me at [RFC 6648](http://tools.ietf.org/html/rfc6648) which, as it clearly states, is about:

> "Deprecating the "X-" Prefix and Similar Constructs in Application Protocols"

It's very RFC-y in it's wording - and it's also only a year old which is really young in RFC time - but it's definitely something to keep in mind when designing custom headers for your application to serve or handle in the future.
