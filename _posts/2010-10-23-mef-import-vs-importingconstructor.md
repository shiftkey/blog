--- 
layout: post
title: MEF - [Import] vs [ImportingConstructor]
description: A compare and contrast article on how Import and ImportingConstructor behave, and the potential pitfalls to watch for
funnelweb_id: 5
date: 2010-10-23 14:00:00 +11:00
tags: "mef import importingconstructor .net "
comments: true
---
A short discussion on Twitter recently started as a result of Jeremy Likness' article on MEF at [InformIT][1]. I recommend reading it for anyone who is looking for an introduction to the MEF concepts.

The healthy debate was ultimately about [Import] being easier than [ImportingConstructor] to use. I disagreed, but at the time couldn't really put my finger on why I preferred it.

After a bit of pondering, this is what I've come up with.

Compare and Contrast - [Import] versus [ImportingConstructor]
----------------------------------------

Compare these two segments of code:

The [Import] version...

    public class TwitterPlugin : IMicroblog
    {
        [Import]
        private IApplicationSettingsService _applicationSettings;

        [Import]
        private IStatusUpdatesService _statusUpdatesService;

        [Import]
        private IContactsService _contacts;

        public TwitterPlugin()
        {
            // some constructor logic
        }
    }

Or the [ImportingConstructor] version...

    public class TwitterPlugin : IMicroblog
    {
        private readonly IApplicationSettingsProvider _applicationSettings;
        private readonly IStatusUpdateService _statusUpdatesService;
        private readonly IContactsService _contactsService;

        [ImportingConstructor]
        public Twitter(IApplicationSettingsProvider applicationSettings,
                       IStatusUpdateService statusUpdateService
                       IContactsService contactsService)
        {
           _applicationSettings = applicationSettings;
           _statusUpdatesService = statusUpdateService;
           _contactsService = contactsService;
        
           // some constructor logic
        }
    }

So the second approach requires more code, but a good tool should have you saving many keystrokes - even Visual Studio 2010 will help out with that.

Other differences:

**Design - Constructor Injection versus Property Setters**

With the first approach, the properties are not populated until after the constructor is completed. If the class needs to perform tasks in the constructor which require its dependencies to be present, then you need to use the [ImportingConstructor] approach.

By using the [ImportingConstructor] attribute, the part declares to the container that it requires. Simple, easy to read, and can be used outside MEF by new'ing it up.

**Maintainability**

Jeremy raised a concern about the constructor signature growing over time, and that a set of properties on the class was a cleaner approach. 

I see the "growing dependency count" as a design issue rather than a technical issue. Tacking on another [Import] attribute should be considered a code smell, just like adding an additional parameter to a constructor.

If your dependency count is more than a handful, then you should review the interfaces and see if they can be segregated/aggregated better. The dependency list is a representation of what the component requires to function. It should be the smallest possible set of interfaces, and no more. The interfaces should be lean and specialized, and classes can implement multiple interfaces if required.

**You can still use attributes**

Something these snippets don't demonstrate is that attributes can be combined with ImportingConstructor for specific scenarios:

For example, using [ImportMany]

    private readonly IEnumerable<ICreditService> _creditServices;

    [ImportingConstructor]
    public BankService([ImportMany] IEnumerable<IProductServices> productServices)
    {
        _productServices = productServices;
        
        // some constructor logic
    }

Or using AllowDefault to allow for scenarios where a component is not known:

    private readonly ILogger _logger;

    [ImportingConstructor]
    public BankService([Import(AllowDefault=true)] ILogger logger)
    {
        if (logger == null)
            _logger = new DefaultLogger();
        else
            _logger = logger;
        
        // some constructor logic
    }

And this still keeps all the composition "magic" in one location. MEF supports importing [properties, fields and collections][2], which could be scattered around the same class. 

**Closing Statements**

Ultimately, I guess I'm advocating the [ImportingConstructor] approach because once a class grows to a significant complexity (requiring some parts and providing other parts) I feel that it is the saner approach.

For getting start with MEF, [Import] works fine - the barrier to entry is lowered greatly. But as the composition graph grows in an application - e.g. A <-> B <-> C <-> D - then I'd start simplifying the classes and pushing more "magic" into the constructor for readability's sake.

While we're talking managing MEF parts
----------------------------------------

When I first started using MEF, I avoided ImportingConstructor like the plague. Every time I saw ImportingConstructor being used, I thought "*Why add a constructor parameter to the constructor when I can just add an attribute?*" 

After all, it just worked.

It was easy to get started with MEF - as the application grows, you can sprinkle some more magic around.

I've been using MEF since the early previews (Preview 6 i think was the first drop I tried out) for various apps. One of the bigger codebases running on MEF is [MahTweets][3], a pluggable WPF client for various social media services.

For an upcoming release, I'm currently refactoring the MahTweets internals to replace StructureMap with Autofac. The [MEF integration extensions for Autofac][4] have been a great help to simplify the integration between Autofac's ContainerBuilder and MEF's ComposablePartCatalog, and I've found ways to reduce the required MEF syntax without changing existing functionality.

On the Autofac side, we can declare components in the container to be available for MEF composition. 

    container.RegisterType<ApplicationSettingsProvider>()
             .As<IApplicationSettingsProvider>()
             .Exported(x => x.As<IApplicationSettingsProvider>()) // make this part visible to MEF components
             .SingleInstance();

    container.RegisterType<PluginSettingsProvider>()
             .As<IPluginSettingsProvider>()
             .Exported(x => x.As<IPluginSettingsProvider>())
             .SingleInstance();

    ...

    // register external plugins for consumption
    container.RegisterComposablePartCatalog(catalog);

This allows for better separation between the application and external parts, and reduces effort required to register a component with both the IoC container and the CompositionContainer.

I'll blog some more in the future on how you can use these parts to help manage MEF applications as they grow. I need to check out the MEF v2 drops first :)


  [1]: http://www.informit.com/articles/article.aspx?p=1635818
  [2]: http://mef.codeplex.com/wikipage?title=Declaring%20Imports&referringTitle=Guide
  [3]: http://www.mahtweets.com/
  [4]: http://code.google.com/p/autofac/wiki/MefIntegration
