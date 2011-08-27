--- 
layout: post
title: Musing - Simpler UI Testing for WPF Apps
description: Instead of the existing tools, why not try some IronRuby and rspec code?
funnelweb_id: 12
date: 2011-03-26 14:00:00 +11:00
tags: "wpf testing "
comments: true
---
After spending some time this week getting to know Ruby and some of its testing frameworks (Shoulda, rspec, and TestCase), I thought I'd put pen
to paper and revisit why I started down this path. 

**Some background**

The current project I am working on is a large data-driven WPF application, with a lot of complex scenarios to
identify, develop and test. There is a group of testers on the project, but I can see an opportunity to use 
automated testing to verify functionality and allow testers to focus on areas of better value - exploratory testing, for example.

Yes, there are frameworks like [White][2] or Coded UI Tests, but these tools were designed with developers in mind.
You have to write code like [this][1] to drive the tests, and the tests are commonly written after the feature is implemented.

**Enter Automated Acceptance Testing**

In an ideal world, business users would define tests in an English-like language, which can then be translated into an executable 
script and run against the application. 

What I'm looking for in a framework for defining use cases:

 - define the test first, so that the high-level scenario is set before development occurs
 - flexible with syntax for test cases - tailor scripts to suit people involved, while remaining declarative
 - integrate into deployment process to verify builds automated

**Some inspiration from obscure corners**

When I first saw the syntax for [webrat][1], I was intrigued and jealous. To declare a test like this:

    class SignupTest < ActionController::IntegrationTest

        def test_trial_account_sign_up
            visit home_path
            click_link "Sign up"
            fill_in "Email", :with => "good@example.com"
            select "Free account"
            click_button "Register"
        end
    end

was not far off what I'd had in mind for something that was easy to follow and easy to write.

So I spent some time this week experimenting with various ways of achieving this against a sample WPF application.

I'm using rspec at the moment to run the test cases, and IronRuby and White to support the integration with the hosted WPF application.

**What does a test for the WPF application look like?**

    describe "new customers screen" do

        subject { Host.new(File.expand_path('./app/WpfTestApp.exe', File.dirname(__FILE__)))

        before(:each) do
            click "Add Customer"
        end

        it "cannot save empty form" do
            cannot_click "Save"
            can_click "Cancel"
        end

        it "can enter details for customer" do
            fill "FirstName", :with => "Brendan"
            fill "LastName", :with => "Forster"
            # and some other fields
            can_click "Save"
        end

        it "can save and return to main screen" do
            fill "FirstName", :with => "Brendan"
            fill "LastName", :with => "Forster"
            # and some other fields
            click "Save"
            assert_title "Dashboard"
        end

        after(:each) do
            cleanup
        end

        def method_missing(sym, *args, &block)
            subject.send sym, *args, &block
        end
    end

The fields used here are based off the UI Automation features of the .NET Framework (some reading [here][2] on recommendations) 
which I'll dig into a bit later if people are interested.

The method_missing method is used to reduce the noise of writing "subject." to start each line - I'm not quite sold on the approach, but it was cleaner than the previous approaches I'd tried. 
Also, rspec has a [huge set of features][4] which I've barely scratched the surface on.

So with a set of files like the file above, the testrunner is a simple script to load specific files found in the current directory:

	require 'rubygems'
	require 'rspec'
	require 'host'

	Dir[File.dirname(__FILE__) + '/*tests.rb'].each do |file| 
	    load file
	end


I'll share some more as I polish additional features (I'm most certainly doing Ruby wrong at the moment, so I keep refactoring code), 
just needed to write this post.

[1]: http://msdn.microsoft.com/en-us/magazine/dd483216.aspx
[2]: http://white.codeplex.com/
[3]: http://windowsclient.net/wpf/white-papers/wpf-app-quality-guide.aspx#uitesting
[4]: https://gist.github.com/663876
