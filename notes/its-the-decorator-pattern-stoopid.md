---
layout: post
title: If it walks like a Func and quacks like a Func...
date: 2013-07-05 13:30:00 +9:30
description: So someone nerd-sniped me to jump in on an internet debate. He might not like my thoughts on this...
---

You can get to the gory details on [how this started](ifrb.info/2013/07/02/funcy-love.html) and then [went further](http://developer.greenbutton.com/make-my-func-the-higher-order-func/) and [further still](http://developer.greenbutton.com/func-ier-and-func-ier/) before some [dissenting voices](http://blog.computercraft.co.nz/2013/07/04/DontGetTooFuncy.aspx) came along.

While I was initially nodding along, as the discussion wore on I kept hearing this in my head...

<iframe width="640" height="360" src="http://www.youtube.com/embed/r9Zimpr_8zs?feature=player_detailpage" frameborder="0" allowfullscreen></iframe>

Well, that was the good part. The part I didn't like comes down to two points:

 - the example scenario used distracted from the initial discussion significantly
 - if we're going to address the example, there's a different way which short-circuits the whole "readability debate"

## We need to tak about The Example

So it all started with code like this:

    public IEnumerable<Order> GetOrders(int customerId)
    {
        string cacheKey = string.Format("OrdersForCustomer{0}", customerId);

        var result = _cacheService.Get<IEnumerable<Order>>(cacheKey);
        if (result == null)
        {
            result = _ordersRepository.GetForCustomer(customerId);
            _cacheService.Add(cacheKey, result);
        }
        return result;
    }

Which roughly matches this

    - Get the value from the cache
    - If it's null:
      * do some work to actually fetch the data from some repository
      * cache the returned data
    - return the result

So we then move this out to an extension method which we can then call everywhere:

    public static class FuncyExtensions
    {
        public T RetrieveAndCache<T>(this ICacheService cacheService, string cacheKey, Func<T> retrieve)
        {
            var result = cacheService.Get<T>(cacheKey);
            if (result == null)
            {
                result = retrieve();
                cacheService.Add(cacheKey, result);
            }
            return result;
        }
    }

And we're done, right? I'm not so sure.

## Tell, don't ask

Have you heard of the [**Hollywood Principle**](http://en.wikipedia.org/wiki/Hollywood_principle)? While it sounds like a thing struggling movie stars have to face, it's a popular buzzword with programmers to discuss how code should have low coupling and high cohesion.

While Ian has gone a way to make this `RetrieveAndCache<T>` method reusable, it's still doing the same two steps:

 - "[hey girl](http://programmerryangosling.tumblr.com/), do you have this thing in the cache?"
 - "[hey girl](http://programmerryangosling.tumblr.com/), can you put this thing in the cache?"

I see this "get, or get then add" pattern as being the responsibility of the cache itself, not of the consuming code. More on this later.

I loved how Ivan brought out this example which allows you to achieve this:

    public static Func<TKey, TResult> Encacheify<TKey, TResult>(
        this ICacheService cacheService,
        Func<TKey, TResult> produceValue,
        Func<TKey, string> makeCacheKey)
    {
        return key =>
        {
            string cacheKey = makeCacheKey(key);
            return cacheService.RetrieveAndCache(cacheKey, () => produceValue(key));
        };
    }

So we're heading in the right direction:

    var cachingGetOrders = _cacheService.Encacheify(
    	(int id) => _ordersRepository.GetForCustomer(id),
    	(int id) => String.Format("OrdersForCustomer{0}", id));

    IEnumerable<Order> alicesOrders = cachingGetOrders(alicesId);  

And yes, that `Encacheify` method is a bit hard to grok.

## What were we doing again?

So having gone down this path (which is excellent and helps to highlight some of the pros and cons of making your code more declarative), let's now try and ground this debate in something practical.

> "We want to cache requests to a service"

That was from the first post, and I do like that goal.

> "We want to improve our separation of concerns"

> "We want to compose features and behaviour"

So Ian nerd-sniped me to jump into this discussion and as I read more I got a bit grumpy that we hadn't really moved beyond code snippets and concepts. So I cloned down the [MVC Music Store](http://mvcmusicstore.codeplex.com) app to see how applying these concepts impacts a real application.

So for this exercise I want to demonstrate three things:

 - how to apply the caching features using the Decorator Pattern
 - how these concepts impact things like readability, maintainablity and flexibility of the codebase
 - is it actually worth it?

## Decorate all the Things!

Coming back to the cache service itself, I've made a small design change to the interface:

    public interface ICacheService
    {
        T Get<T>(string key, Func<T> produceResult);
    }

And it has a simple implementation:

    // TODO: handle cross-threading concerns
    // TODO: handle expiration concerns
    public class InMemoryCacheService : ICacheService
    {
        readonly IDictionary<string, object> storage = new Dictionary<string, object>();

        public T Get<T>(string key, Func<T> produceResult)
        {
            object value;
            if (storage.TryGetValue(key, out value))
                return (T)value;

            var newValue = produceResult();
            storage[key] = newValue;

            return newValue;
        }
    }

The cache is responsible for maintaining it's own state - and so consumers do not need to worry about adding items to the cache.

Next up we have a simple repository interface:

    public interface IArtistsRepository : IDisposable
    {
        IEnumerable<Artist> GetAll();
    }

Which has a simple implementation:

    public class ArtistsRepository : IArtistsRepository
    {
        readonly MusicStoreEntities context = new MusicStoreEntities();

        public IEnumerable<Artist> GetAll()
        {
            return context.Artists.ToList();
        }

        // **boring Dispose code here**
    }

Boring, boring, boring stuff.

So rather than adding the caching code into this class (Func or no Func), I can create a new component which matches the `IArtistRepository` interface and decorates this behaviour with the necessary caching code:

    public class ArtistsRepositoryCache : IArtistsRepository
    {
        readonly IArtistsRepository repository;
        readonly ICacheService cacheService;

        public ArtistsRepositoryCache(IArtistsRepository repository, ICacheService cacheService)
        {
            this.repository = repository;
            this.cacheService = cacheService;
        }

        public void Dispose()
        {
            repository.Dispose();
        }

        public IEnumerable<Artist> GetAll()
        {
            return cacheService.Get("artists-all", () => repository.GetAll());
        }
    }

It doesn't know anything about the underlying repository. It only takes care of the caching scenarios, and calls to the underlying repository code when it needs data.

At this point you need an IoC container to do the wireup of the components at startup. That's this code:

    var builder = new ContainerBuilder();
    var thisAssembly = typeof(MvcApplication).Assembly;
    builder.RegisterControllers(thisAssembly);

    // register all the repositories
    builder.RegisterAssemblyTypes(thisAssembly)
           .Where(t => t.Name.EndsWith("Repository") && !t.IsInterface)
           .AsImplementedInterfaces();

    // register the caching service
    builder.RegisterType<InMemoryCacheService>().AsImplementedInterfaces();

    // register the caching providers as decorators
    builder.RegisterDecorator<IArtistsRepository>(
        (c, inner) => new ArtistsRepositoryCache(inner, c.Resolve<ICacheService>()), "repository");

    var container = builder.Build();
    DependencyResolver.SetResolver(new AutofacDependencyResolver(container));

The working app is [here](https://github.com/shiftkey/mvc-music-store/tree/decorator-pattern-demo).

## Pros and Cons

Our caching code is separated from the repository implementation and encapsulated in it's own class. This isn't as elegant as the "turtles all the way down" approach we've discussed before, but gives us the freedom to do things like:

 - for example, expire frequently-changing components quicker than others
 - inject a strategy object into the cache and control when the cache is used

## TODO:

 - simplify the cache repos to subclass
 - injecting a strategy object?
 - EF context per HttpContext?
