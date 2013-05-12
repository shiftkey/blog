---
layout: post
title: Yet Another "Add LESS to your ASP.NET MVC Project" Post
date: 2013-05-12 23:00:00 +10:00
description: I had to write this because it was really annoying the last time I did it
permalink: /blog/yet-another-implement-less-in-aspnetmvc-post.html
icon: /img/main/less.png
comments: true
---

## You've probably done this too

If you kicked off a new ASP.NET webapp recently, somewhere after `File -> New Project` you probably got excited about using a CSS preprocessor like LESS or SASS because:

 - nobody writes CSS directly anymore
 - it's supposed to make your life easier
 - something with unicorns and rainbows

This post isn't about that. This is about the little quirks I had to jump through to get a usable development environment for writing LESS code.

NOTE: This uses the bundling features in MVC4. If you're using a version of MVC which is older than that, go upgrade. Bundling is **so nice**.

## Step 1 - The Installer-ation

    PM> Install-Package dotLess

Go run that in a new project. I'll wait.

Done? Great, so go write a little LESS code (I've just called this file `sample.less` for the purposes of this demo):

{% highlight css %}
@color: #4D926F;

.site-title a {
  color: @color;
}
h3 {
  color: @color;
}
{% endhighlight %}

And then include it in your Razor layout...

{% highlight xml %}
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>@ViewBag.Title - My ASP.NET MVC Application</title>
        <link href="~/favicon.ico" rel="shortcut icon" type="image/x-icon" />
        <meta name="viewport" content="width=device-width" />
        @Styles.Render("~/Content/less")
        @Scripts.Render("~/bundles/modernizr")
    </head>
    <!--  and more stuff here obvs -->
{% endhighlight %}

But you're application doesn't know about *how* it can transform LESS code into CSS. That's where bundles come in.

## Step 2 - Dude, where's my bundle?

Bundles are an easy way to merge and minify resources in your application (such as JavaScript files and CSS stylesheets). In addition to being a lovely convenience, it's actually a great way to improve site performance (fewer HTTP requests, reducing size of response payload).

So go install this library from NuGet:

    PM> Install-Package System.Web.Optimization.Less

And add your bundle to the appropriate location within `BundleConfig.cs`

{% highlight csharp %}
public class BundleConfig
{
    public static void RegisterBundles(BundleCollection bundles)
    {
    	// NOTE: existing bundles are here 

    	// add this line
        bundles.Add(new LessBundle("~/Content/less").Include("~/Content/*.less"));
    }
}
{% endhighlight %}

Bundles support a limited subset of wildcard syntax, but you can include multiple folders within a bundle.

The details about the history of this code project are a bit thin, but I initially found this code in a [gist](https://gist.github.com/benfoster/3924025) from [@benfosterdev](http://ben.onfabrik.com/) so I'll give him kudos for it.

So this `LessBundle` gives you the ability to combine and minify files when running the application in `<compilation debug="false" />` mode, without needing to update the layout everytime you add a new file to the project - it's all centralized in the bundle configuration.

## Step 3 - But wait, there's more!

But what about when you're just testing locally? 

Bundles are rather lazy in development mode:

 - no minification
 - no bundling
 - in fact the files just ship as LESS resources to the browser

So you *still* need to tell your application how it can serve LESS files to the browser, independent all this bundling work.

dotLess will apply transforms to your web.config when you install it through NuGet to provide handlers which can process a specific LESS file:

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <section name="dotless" type="dotless.Core.configuration.DotlessConfigurationSectionHandler, dotless.Core" />
  </configSections>
  <!-- these probably do something useful -->
  <dotless minifyCss="false" cache="true" web="false" />
  <system.webServer>
    <handlers>
      <!-- for IIS7+ -->
      <add name="dotless" path="*.less" verb="GET" type="dotless.Core.LessCssHttpHandler,dotless.Core" resourceType="File" preCondition="" />
    </handlers>
  </system.webServer>
  <system.web>
    <httpHandlers>
      <!-- for IIS6 -->
      <add path="*.less" verb="GET" type="dotless.Core.LessCssHttpHandler, dotless.Core" />
    </httpHandlers>
  </system.web>
</configuration>
{% endhighlight %}

Editor's Note: when I last ran through these steps I didn't get these config transforms applied on install. I was really looking forward to a rant here because I'd gone through the hard yards to add these handlers by hand - but of course it worked this time. 

So these handlers allow you to compile an individual LESS file and see the results in the browser.

![](/img/posts/less/dev-experience.png)

Oh, and don't forget to remove the handlers in your config transforms when you go to production (this is an example of the `Web.Release.Config` config transforms file).

{% highlight xml %}
<?xml version="1.0"?>
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">
  <system.web>
    <compilation xdt:Transform="RemoveAttributes(debug)" />
    <httpHandlers>
      <add xdt:Transform="Remove" xdt:Locator="Match(type)" path="*.less" verb="GET" type="dotless.Core.LessCssHttpHandler, dotless.Core" />
    </httpHandlers>
  </system.web>
  <system.webServer>
    <handlers>
      <add xdt:Transform="Remove" xdt:Locator="Match(name)" name="dotless" path="*.less" verb="GET" type="dotless.Core.LessCssHttpHandler,dotless.Core" resourceType="File" preCondition="" />
    </handlers>
  </system.webServer>
</configuration>
{% endhighlight %}