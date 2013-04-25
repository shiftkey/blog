--- 
layout: post
title: IoC Tips - Autofac Factory Adapters
permalink: /ioc-tips-autofac-factory-adapters.html
description: A walkthough about applying inversion of control techniques to simplify an existing application
funnelweb_id: 4
date: 2010-10-23 14:00:00 +11:00
tags: "autofac .net"
comments: true
---

## Scenario

A team has a change request come in from the business. For one of their screens, a timer should count up when a user pauses the current task.

As the application was already using an IoC container (Autofac), and a timer was already implemented to provide the behaviour for a similar task in this class, the constructor was quickly changed to:

	public ScheduledBackupService(
		  ... ,
	      ITimer elapsedTimer,
	      ITimer pausedTimer)
	{
	      ...
	      this.elapsedTimer = elapsedTimer;
	      this.pausedTimer = pausedTimer;
	      ...
                       

And from there they added in the additional code required, and the business was happy. And there was much rejoicing. But the team noticed that they were duplicating the same type in the constructor. Can the team do it better?

Rather than explicitly defining the two instances, the team can replace both instances with a factory adapter. In .NET, this can be represented as a `Func<T>` object - a method which requires no inputs and returns an instance of type T:

	public ScheduledBackupService(
	      ... , 
	      Func<ITimer> createTimer)
	{
	      ...                 
	      elapsedTimer = createTimer();
	      pausedTimer = createTimer();
	      ...

To fix the compiler error from changing the constructor signature, the test code is updated to:

	private IScheduledBackupService GetScheduledBackupService()
	{
		return new ScheduledBackupService(
		            ... ,
		            () => MockRepository.GenerateStub<ITimer>());
	}

## What about those unit tests?

What if we need to use the mock object in a unit test - to raise events or stub methods? We can't track them if we use the function defined above...

As our existing tests relied on verifying the messages displayed using ITimer instances, I wrote a custom function to mimic the function behaviour and support the unit tests.

    private Func<IDispatcherTimer> createTimers = () =>
    {
        if (elapsedTimer == null) 
        {
            // first call -> mock "elapsed" timer
            elapsedTimer = MockRepository.GenerateStub<ITimer>();
            return elapsedTimer;
        }
        if (pausedTimer == null) 
        {
            // second call -> mock "paused" timer
            pausedTimer = MockRepository.GenerateStub<ITimer>(); 
            return pausedTimer;
        }
	      
        return null; // subsequent calls not supported - will raise errors if used
    };

    private IScheduledBackupService GetScheduledBackupService()
    {
        return new ScheduledBackupService(
                        ... ,
                        createTimers);
	}


And our tests remain clean and readable:

    [TestMethod]
    public void ElapsedTimer_WhenServiceResumes_StartsAgain()
    {
        // arrange
        var service = GetScheduledBackupService();

        // act
        service.Start();
        service.Pause();
        service.Resume();

        // assert
        elapsedTimer.AssertWasCalled(s => s.Start(), m => m.Repeat.Twice());
        elapsedTimer.AssertWasCalled(s => s.Stop(), m => m.Repeat.Once());
    }


## What else can I do from the container?

Nicholas Blumhardt, maintainer of Autofac, has a [detailed entry][1] which discusses the different possible relationships between components, and how Autofac defines them. While the article is Autofac-centric, many of the other inversion of control containers for the .NET Framework support some of the features already.

A great read if you want to dive deeper into inversion of control concepts.

   [1]: http://nblumhardt.com/2010/01/the-relationship-zoo/


