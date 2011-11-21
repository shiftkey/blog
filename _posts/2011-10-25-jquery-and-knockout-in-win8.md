--- 
layout: post
title: jQuery and KnockoutJS in Win8? Sure, why not!
permalink: jquery-knockout-win8.html
description: A brief experiment after a couple of questions from a user group event tonight
date: 2011-10-25 23:00:00 +10:00
icon: /img/main/win8.jpg
tags: "jquery knockoutjs windows8"
comments: true
---

Apparently this is old news to some. Trendsetters...

With Windows 8 supporting HTML/JS (I refuse to call anything HTML5 these days - the words have lost all meaning to me, but that's another topic) applications, I was asked if [jQuery][3] is supported - with a goal to making JS applications more maintainable.

 [3]:http://jquery.com/

As I'd heard it mentioned at BUILD - and hadn't heard a major drama since people have been using the Developer Preview bits - I expected that it worked. However, to confirm this for myself, I found this [forum thread][1] on MSDN with a couple of caveats. 

 [1]: http://social.msdn.microsoft.com/Forums/en-US/winappswithhtml5/thread/66273417-92cd-4a35-b9a1-281d962eff59

No fire and brimstone? Oh well, I'll just double-check...

After adding the jQuery file to the project, I modified the **default.html** file to include the jQuery file **before** the default.js file. The default.js file contains the bootstrapping code for the application:

<pre><code>   &lt;link rel="stylesheet" href="/css/default.css" /&gt;
    <strong>&lt;script src="/js/jquery-1.6.4.js"&gt;&lt;/script&gt;</strong>
    &lt;script src="/js/default.js"&gt;&lt;/script&gt;
&lt;/head&gt;

</code></pre>

And at the bottom of the default.js file, I use a simple selector to find a DOM element:

<pre><code>            // other code

            WinJS.UI.process(<strong>$('#appbar')[0]</strong>)
                .then(function () { 
                    <strong>$('#home').click(navigateHome);</strong>
                });

            WinJS.Navigation.navigate(homePage);

            <strong>var host = $('#contentHost');</strong>
        }
    }

    WinJS.Navigation.addEventListener('navigated', navigated);
    WinJS.Application.start();

})();
</code></pre>

and started making use of selectors elsewhere instead of document.getElementById to make the code more concise...

## And what of KnockoutJS?

I've only had basic experience with [Knockout][2], but found an easier scenario to support. I dropped in the code and modified the detailPage template.

 [2]:http://knockoutjs.com/

<pre><code>   &lt;link rel="stylesheet" href="/css/default.css" /&gt;
    &lt;link rel="stylesheet" href="/css/detailPage.css" /&gt;
    &lt;script type="ms-deferred/javascript" src="/js/detailPage.js"&gt;&lt;/script&gt;
    <strong>&lt;script type="ms-deferred/javascript" src="/js/knockout-1.2.1.js"&gt;&lt;/script&gt;</strong>
&lt;/head&gt;

</code></pre>

And then went to work making changes:

**In detailPage.js**

*Before*

    function fragmentLoad(elements, options) {
        var item = options && options.item ? options.item : getItem();
        elements.querySelector('.pageTitle').textContent = item.group.title;

        WinJS.UI.processAll(elements)
            .then(function () {
                elements.querySelector('.title').textContent = item.title;
                elements.querySelector('.content').innerHTML = item.content;
            });
    }

*After*

<pre><code>function fragmentLoad(elements, options) {
    var item = options &amp;&amp; options.item ? options.item : getItem();
    WinJS.UI.processAll(elements).then(function () { <strong>ko.applyBindings(item);</strong> });
}
</code></pre>

**In detailPage.html - declared some bindings using the data-bind attribute**

<pre><code>&lt;div class="detailPage fragment"&gt;
    &lt;header role="banner" aria-label="Header content"&gt;
        &lt;button disabled class="win-backbutton" aria-label="Back"&gt;&lt;/button&gt;
        &lt;div class="titleArea"&gt;
            &lt;h1 class="pageTitle win-title" <strong>data-bind="text: group.title"</strong>&gt;&lt;/h1&gt;

        &lt;/div&gt;
    &lt;/header&gt;
    &lt;section role="main" aria-label="Main content"&gt;
        &lt;article&gt;
            &lt;div&gt;
                &lt;header&gt;

                    &lt;h1 class="title win-contentTitle" <strong>data-bind="text: title"</strong>&gt;&lt;/h1&gt;
                &lt;/header&gt;
                &lt;div class="image" <strong>data-bind="style: { color: backgroundColor }"</strong>&gt;&lt;/div&gt;
                &lt;div class="content" <strong>data-bind="html: content"</strong>&gt;&lt;/div&gt;
            &lt;/div&gt;

        &lt;/article&gt;
    &lt;/section&gt;
&lt;/div&gt;
</code></pre>

So by moving the binding expressions to the UI (like the MVVM pattern that is popular with XAML application) we can lean on frameworks to make our Javascript code easier to maintain. Other components of the default templates have their own binding attributes - *data-win-bind* - which I'll explain later, but I find the KnockoutJS syntax more concise. 

In particular the use of *textContent* instead of *text* to denote a text value? Why? Drop the 'Content' part unless there's a real good reason - it feels like ceremony.

I'll formulate some more opinions on the WinJS side as I delve deeper....