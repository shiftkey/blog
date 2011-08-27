--- 
layout: post
title: slsvcutil - Workaround StackOverflowException
description: Mental reminder for an issue I hit today with generating Silverlight proxies using slsvcutil
funnelweb_id: 14
date: 2011-05-06 14:00:00 +10:00
tags: "silverlight "
comments: true
---
I've hit this issue before, but it took a bit of googling to remember the fix - especially since that little site called [stackoverflow][1] came into the mix :)

[1]: http://www.stackoverflow.com/

    D:\Readify\Hg\ReadifySample\src>"C:\Program Files (x86)\Microsoft SDKs\Silverlight\v4.0\Tools\Slsvcutil.exe" http://localhost:47862/Services/ParentService.svc

    Process is terminated due to StackOverflowException.

No configuration options set. No informative error message. Annoying.

The solution, which was initially posted [here][2] over a year ago, is to add in a configuration file alongside slsvcutil.exe, called **slsvcutil.exe.config**, which will point to the neutral-culture assembly.

[2]: http://blogs.msdn.com/b/silverlightws/archive/2010/04/30/workaround-for-stackoverflowexception-when-using-slsvcutil-exe.aspx

    <configuration>
      <satelliteassemblies>
        <assembly name="SlSvcUtil, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" />
      </satelliteassemblies>
    </configuration>


That's right. If you have set your system language to something **other than US English**, you will probably encounter this issue.

Enjoy.
