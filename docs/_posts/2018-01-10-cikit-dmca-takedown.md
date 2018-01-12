---
date: 2018-01-10 12:12:00
title: "DMCA notice for taking down the CIKit"
excerpt: "Legal litigation instead of New Year's mood."
toc_label: "Paragraphs"
toc: true
header:
  teaser: /assets/posts/2018-01-08-cikit-dmca-takedown/dmca-copyright.png
tags:
  - open source
  - cikit
  - copyright wars
---

![DCMA Copyright](/assets/posts/2018-01-08-cikit-dmca-takedown/dmca-copyright.png)

On January 2 I got an email from Github that was stating that [CIKit has received the takedown notice](https://github.com/github/dmca/blob/master/2018/2018-01-02-CIKit.md) due to the [Digital Millennium Copyright Act](https://help.github.com/articles/dmca-takedown-policy) and repository will be disabled within 24 hours if the content, infringing the copyright of CIBox, will not be removed.

CIKit and CIBox - are close by spirit, but vary in underlying approaches. Let's take a look closer.

## Brief preamble

[Andrii Podanenko](https://github.com/podarok), the man who had published [my first project on Drupal.org](https://www.drupal.org/project/fpp_bundles) because I had no rights and enough experience, the man who had advised me a [nice book](https://en.wikipedia.org/wiki/The_Goal_(novel)) and with whom I had an interesting talk while we were walking Barcelona's streets, the man who had inspired many people to contribute to the open source and who had created an uncountable number of projects of different complexity decided that [CIKit](https://github.com/BR0kEN-/cikit) infringe the copyright of [CIBox](https://github.com/cibox/cibox).

If you have read [the complaint](https://github.com/github/dmca/blob/master/2018/2018-01-02-CIKit.md), the claim is pellucid: *CIKit - is a renamed CIBox that violates [BSD license](https://github.com/cibox/cibox/blob/master/LICENSE.txt), where the copyright owner is changed from Andrii Podanenko to Sergii Bondarenko.*

## Takedown request review

Right after receiving the takedown notice I immediately sent my [counter-notice](https://github.com/github/dmca/blob/master/2018/2018-01-03-CIKit-CounterNotice.md). Let's stop at some points of it.

![Files to take down](/assets/posts/2018-01-08-cikit-dmca-takedown/dmca--files.png)

"most of them" - is not even close to the legal statement. The [content by the link](https://github.com/BR0kEN-/cibox/commit/58c949b1d2cf79deb3a8c742a1f489957a5862f0) shows how "cibox" was renamed to "cikit" and the amusing moment is that CIBox never had the renamed codebase.

![Forks](/assets/posts/2018-01-08-cikit-dmca-takedown/dmca--forks.png)

Surprisingly that 7 other forks of CIKit for today are not the problem even despite they have "infringing" content. Perhaps, because their author is not [Sergii Bondarenko](https://github.com/BR0kEN-).

1. [https://github.com/Mitsuroseba/cibox-1](https://github.com/Mitsuroseba/cibox-1)
2. [https://github.com/kapoldi/cikit](https://github.com/kapoldi/cikit)
3. [https://github.com/sb3838438/cikit](https://github.com/sb3838438/cikit)
4. [https://github.com/Selitbovskaya/cikit](https://github.com/Selitbovskaya/cikit)
5. [https://github.com/spheresh/cikit](https://github.com/spheresh/cikit)
6. [https://github.com/stalliobn/cibox](https://github.com/stalliobn/cibox)
7. [https://github.com/gajdamaka/cibox](https://github.com/gajdamaka/cibox)

Focusing at [https://github.com/gajdamaka/cibox](https://github.com/gajdamaka/cibox/tree/f6639d50923d36969871ba48ecb0343774f761e0) we may see the fork had been created 2 years ago - on November 18, 2015. Does it, even a bit, looks close to [CIBox at those days](https://github.com/cibox/cibox/tree/efcfa59893908b65659ac1925230681e5549fb07)?

![Licence violation](/assets/posts/2018-01-08-cikit-dmca-takedown/dmca--license.png)

[This](https://www.facebook.com/groups/drupal.ua/permalink/10155789972390218/?comment_id=10155790653055218&reply_comment_id=10155798205185218) is not a query to "fix license issues". Apart from that impulsive comment, no one even tried to reach me out.

**Curious fact**, that when I wanted to check [the post on Facebook](https://www.facebook.com/groups/drupal.ua/permalink/10155789972390218), I didn't manage to find it. I was a bit saddened that someone of admins has removed the post even despite I made the screenshots of the entire conflict. Later on, I found it, visiting the group in incognito mode - it turned out that [Andrii](https://www.facebook.com/podarok) blocked my account on his end. It became interesting to me where else apart from Facebook, and I found that he blocked me everywhere where the "block" button exists: LinkedIn, Twitter, unsubscribed me on Github...
{: .notice--info}

As I already stated on Facebook, **I'm ready to remove all CIBox stuff from CIKit** to not infringe the copyright. Just find that content and point me out onto it.

## Facts sheet

Let's answer some questions first to start modeling the situation.

### When was CIBox born?

Officially, on [September 3, 2014](https://github.com/cibox/cibox/commit/00d602bb8b5ae65faa94a14de3c331dd8df4f41a).

### When was CIKit born?

Officially, on [November 9, 2015](https://github.com/BR0kEN-/cikit/commit/c4f4dd8b86e27c068a94b7022b7910b235c9e9ab). But until December 24, 2016, it was named **BR0kEN-/cibox** under the original license, belonging to Andrii Podanenko.

### When I made the first contribution to CIBox?

On [March 16, 2016](https://github.com/cibox/cibox/commit/9864379dce1fdf7e54b8b1b45c97ca80e6e3d0db).

### When CIKit changed copyright owner?

On [December 24, 2016](https://github.com/BR0kEN-/cikit/commit/6245de17ae533294b24bdacab54493c32cb54fb3) CIKit got the copyright owner in a face of Sergii Bondarenko instead of Andrii Podanenko.

On a timeline it might look like:

![CIBox/CIKit timeline](/assets/posts/2018-01-08-cikit-dmca-takedown/cibox-cikit-timeline.png)

The **BR0kEN-/cibox** will be used instead of **CIKit** below because this article mostly touches the earlier period of the project when it had the license, inherited from CIBox and the "CIKit" name wasn't coined.
{: .notice--warning}

### Why was CIKit born instead of focusing on contributing to CIBox?

Well, it is the question I was asked by numerous people and the answer consists of several reasons:

- I had the completely different view of the main approaches in CIBox, such as Ansible playbooks runner, provisioning style of Vagrant, DRY principles, location of unrelated codebase within the project root and so on.
- The main CIBox team, focused on building the core, locates in a different city and, without a close contact, I cannot imagine a development of complex solutions. It is not a lie to say that I was lazy to build a relationship but, on the other hand, have been getting the same. “Let’s do with us” is all I heard approximately 3-4 times for 2 years. Anyway, I do believe **the team that seldom meets each other or constantly works remotely - is nothing more than a group of people**.
- An absence of pull requests review. They getting merged right after creation, eliminating the chance to write a review for approximately [20 contributors](https://github.com/cibox/cibox/graphs/contributors).

### What is wrong with running Ansible playbooks in CIBox?

The CIBox style - is to have a shell script per Ansible playbook. Two playbooks - two scripts, twenty playbooks - twenty scripts, `N` playbooks - `N` scripts. I counted 9 pieces just as of today.

1. [provision.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/provision.sh)
2. [repository.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/repository.sh)
3. [requirements.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/requirements.sh)
4. [check_updates.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/check_updates.sh)
5. [reinstall.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/reinstall.sh)
6. [runcodestyleautofix.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/runcodestyleautofix.sh)
7. [rundevops.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/rundevops.sh)
8. [runsniffers.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/runsniffers.sh)
9. [runtests.sh](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/runtests.sh)

In the very first commit to forked CIBox I've created the [ansible.sh](https://github.com/BR0kEN-/cibox/blob/c4f4dd8b86e27c068a94b7022b7910b235c9e9ab/ansible.sh) to eliminate production of shell scripts per playbook. Single runner - that's what I needed.

### What is wrong with Vagrant provisioning in CIBox?

In short: it is too complex and brings an undesired difference to the provision of VM and CI server. Let's have a look at [provisioning configuration in CIBox's Vagrantfile](https://github.com/cibox/cibox/blob/efcfa59893908b65659ac1925230681e5549fb07/github/files/vagrant/box/Vagrantfile#L82-L96).

```ruby
config.vm.provision "shell" do |s|
  s.path = "provisioning/shell/initial-setup.sh"
  s.args = "/vagrant/provisioning"
  end

# Install ansible inside the box.
config.vm.provision :shell, :path => "provisioning/shell/ansible.sh"

# Install ansible playbooks inside the box.
config.vm.provision :shell, :path => "provisioning/ansible/run-ansible-playbook.sh"

# Install drupal within vm for testing.
if !ENV['VAGRANT_CI'].nil?
  config.vm.provision :shell, :path => "provisioning/ansible/run-drupal-playbook.sh"
end
```

3 shell scripts used as provisioners: [initial-setup.sh](https://github.com/cibox/cibox/blob/efcfa59893908b65659ac1925230681e5549fb07/github/files/vagrant/box/provisioning/shell/initial-setup.sh), [ansible.sh](https://github.com/cibox/cibox/blob/efcfa59893908b65659ac1925230681e5549fb07/github/files/vagrant/box/provisioning/shell/ansible.sh), [run-ansible-playbook.sh](https://github.com/cibox/cibox/blob/efcfa59893908b65659ac1925230681e5549fb07/github/files/vagrant/box/provisioning/ansible/run-ansible-playbook.sh) Moreover, you can find a [bunch of others](https://github.com/cibox/cibox/tree/efcfa59893908b65659ac1925230681e5549fb07/github/files/vagrant/box/provisioning) in there... **BR0kEN-/cibox** [got rid of all of them](https://github.com/BR0kEN-/cibox/commit/dae5d7b7e14d0b047706616acd084c924a214dac) on November 16, 2015, in favor of an unified way of provisioning [virtual machines](https://github.com/BR0kEN-/cibox/tree/dae5d7b7e14d0b047706616acd084c924a214dac/vagrant/Vagrantfile#L71) and continuous integration servers using a single Ansible playbook.

```ruby
config.vm.provision :host_shell, :inline => "./ansible.sh provisioning/provision --limit=vagrant"
```

So, to provision CIBox VM we have a plenty shell scripts and for **BR0kEN-/cibox** VM we have single [provision.yml](https://github.com/BR0kEN-/cibox/tree/dae5d7b7e14d0b047706616acd084c924a214dac/scripts/provision.yml) playbook. Now, how to provision CI server?

**CIBox**: run the [run.sh](https://github.com/cibox/cibox/blob/efcfa59893908b65659ac1925230681e5549fb07/run.sh) that will run the [jenkinsbox.yml](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/services/jenkinsbox.yml) playbook.

**BR0kEN-/cibox**: run the [ansible.sh](https://github.com/BR0kEN-/cibox/tree/dae5d7b7e14d0b047706616acd084c924a214dac/ansible.sh) that will run the [provision.yml](https://github.com/BR0kEN-/cibox/tree/dae5d7b7e14d0b047706616acd084c924a214dac/scripts/provision.yml) playbook.

I recommend taking a look at last two shell scripts now (and playbooks as well) because the takedown request says that `ansible.sh`, the script I'm an author of and the script that has never been a part of CIBox, just had been renamed.
{: .notice--warning}

The state of **BR0kEN-/cibox** for **November 16, 2015** is compared with **CIBox** for **November 22, 2015**.
{: .notice--info}

### What is wrong with a mess of project codebase, mixed with CIBox scripts?

The question stores the answer. CIBox-related stuff locates within `docroot` of your project, where no extra codebase is preferred. Will it be a surprise to know that **BR0kEN-/cibox** overcame this on [November 11, 2015](https://github.com/BR0kEN-/cibox/commit/c18b0244f1a11ec2051eee9d8232a153058edd0b)? CIBox still continue following [this way](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/tasks/drupal.yml#L136-L137)...

### Does CIBox have Ansible 2.x compatibility?

It still requires you to use [1.9.6](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/requirements.sh#L12) despite [2.x has been released on January 12, 2016](https://github.com/ansible/ansible/releases/tag/v2.0.0.0-1). Meanwhile, [BR0kEN-/cibox became Ansible 2.x compatible](https://github.com/BR0kEN-/cibox/commit/04074678f3533e7325d241a4349f3c992edc7f92) on January 17, 2016.

### What is wrong with CIBox nowadays?

This is a personal review of the competing product so it does not pretend to be objective and not aimed to insult anyone from CIBox team.
{: .notice--info}

Will you say I pervert if I say I commit `node_modules` to repositories? CIBox team does not hesitate to not just do this but makes an exact copy of an entire folder in a  different location and commit `node_modules` multiplied by two. Check these two folders by yourself: [one](https://github.com/cibox/cibox/tree/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal7/scripts/devops/HTML_CodeSniffer/node_modules), [two](https://github.com/cibox/cibox/tree/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/files/drupal8/scripts/devops/HTML_CodeSniffer/node_modules).

![node_modules weight in the Universe](/assets/posts/2018-01-08-cikit-dmca-takedown/node-modules-weight.jpg)

Other moments:

- Numerous shell scripts are nowhere gone.
- The CIBox-related stuff is still within your `docroot`.
- Ansible scripts still do not compatible with 2.x, while [CIKit has dropped off support of versions lower than 2.4](https://github.com/BR0kEN-/cibox/commit/c6448439ba1b289af54f126fc166e3cd96738818).
- CIBox still on [Jenkins 1.6](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-jenkins/defaults/main.yml#L43) when **BR0kEN-/cibox** got [migrated to 2.x](https://github.com/BR0kEN-/cibox/commit/b596bd97db2476410e179f9a31597cac61f90130) on December 24, 2016, and now uses latest available version.
- Provisioning of VM and CI still quite different and this reduces the interoperability of environments replication. CIKit does not have this problem an enduring portion of the time.
- CIBox never had a tool for creating a matrix of CI servers when **BR0kEN-/cibox** got it on [March 4, 2016](https://github.com/BR0kEN-/cibox/commit/f16f349bbbbdeb1a74f73194cedd545dc96099e7).
- [CIBox supports a Drupal only](https://github.com/cibox/cibox/blob/f21dffb49fdf52711b02ff13d962a20db8fdc7f4/core/cibox-project-builder/tasks/main.yml#L3), while CIKit has predefined [CI scripts for WordPress](https://github.com/BR0kEN-/cikit/commit/775863771ed15aed10774877615f6fa6e8ca63b5), presented on November 17, 2015, and an API for integrating any framework or CMS.
- CIBox never had the [Vagrant provisioner](https://github.com/BR0kEN-/cibox/commit/e2524f3ce701e745ed726bcd7eaadafc02ee00d6) for controlling VM preparation process and providing operability on Windows hosts. It was introduced in **BR0kEN-/cibox** on November 23, 2015.
- CIBox has never used [Nginx on CI servers](https://github.com/BR0kEN-/cibox/commit/442050d5bf8ab784a4a27ed1616bf87ddcb86083) while **BR0kEN-/cibox** got it on March 1, 2016.

The [change of license and the copyright owner](https://github.com/BR0kEN-/cibox/commit/6245de17ae533294b24bdacab54493c32cb54fb3) of **BR0kEN-/cibox**, alongside with [renaming project to CIKit](https://github.com/BR0kEN-/cibox/commit/85545e5d2488e048dfac8c6bb5d1f6f60821ea1a) and detaching it from CIBox on Github has happened on **December 24, 2016**.
{: .notice--warning}

### What are the distinguishing features of CIKit nowadays?

- [Single-line installation as a system package](/documentation/#installation), that is focused to not ship core files with a project and to make the upgrade process easier.
- [Update manager](/documentation/#update) with an ability to run necessary tasks on version transition.
- The controlling utility - `cikit` - is written in Python, the same language as Ansible. It allows you to pass/override variables of playbooks as options to a command.
- Scripts for provisioning a server that will play a role of a [hosting for CI servers](/documentation/matrix/) in Docker-based containers.
- A [manager of hosts](/documentation/hosts-manager/) allowing you to keep the credentials of your servers in a single place.
- [Ubuntu 16.04](/changelog/2017-05-18/) everywhere: VM, CI, matrix (still 14.04 in CIBox and it's [almost reached its end of life](/changelog/2017-04-29/)).
- Interaction with users for [choosing the versions of software](/changelog/2017-04-25/) they prefer to install.
- Environment [configuration that stores in YAML](/documentation/project/env-config/) and distributes among all the users.
- Full local-to-CI environment replication.
- Completion scripts (Bash) for the `cikit` utility.
- Full support of [operation on Windows Subsystem for Linux](/documentation/install-on-wsl/).
- Ansible [SSH pipelining](/changelog/2017-12-20/) for accelerating the process.
- Newer versions of the software: Java, Solr, Selenium, MySQL.
- Microsoft SQL Server, Nginx, Ruby - never been a part of CIBox.
- [Ansible inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html) that is forming automatically for droplets and manually via [hosts manager](/documentation/hosts-manager/).

![X-Men as CIBox and CIKit](/assets/posts/2018-01-08-cikit-dmca-takedown/x-men-cibox-cikit.jpg)

### Third-party open source inside of CIBox

#### Case one

[puphpet/puphpet](https://github.com/puphpet/puphpet/tree/50dcab55392bbbe6d30a5a86b4969cf45f38ceab/archive/puphpet) is a part of CIBox since the beginning.

Here is the state of CIBox on October 2017:

![CIBox at f21dffb49fdf52711b02ff13d962a20db8fdc7f4](/assets/posts/2018-01-08-cikit-dmca-takedown/cibox-f21dffb49fdf52711b02ff13d962a20db8fdc7f4.png)

And the PuPHPet on June 2016 (and later). You can walk around the repositories and ensure by yourself.

![PuPHPet at 50dcab55392bbbe6d30a5a86b4969cf45f38ceab](/assets/posts/2018-01-08-cikit-dmca-takedown/puphpet-50dcab55392bbbe6d30a5a86b4969cf45f38ceab.png)

#### Case two

The [Ansible role for Jenkins installation](https://github.com/cibox/cibox/blob/ae6ab8bfa579b9da74bdbb3e9a03f294d25ae62f/core/cibox-jenkins/defaults/main.yml#L60-L61) stores the links to modified, MIT-licensed, [https://github.com/afonsof/jenkins-material-theme](https://github.com/afonsof/jenkins-material-theme).

#### Case three

The codebase for building CIBox-structured repositories came in sight on [February 1, 2016](https://github.com/cibox/cibox/commit/4751a7e3b8c27aa249859d3ba27935b92641b5b5). In **BR0kEN-/cibox** it was introduced on [November 9, 2015](https://github.com/BR0kEN-/cikit/commit/c4f4dd8b86e27c068a94b7022b7910b235c9e9ab/scripts/drupal.yml). Nobody knows how this idea came to CIBox team. Perhaps they themselves came up with this or borrowed from **BR0kEN-/cibox** - I don't know and I don't care.

The world of open source is wonderful and exists, assuming I'll be made a dough and you'll come and bake a bread.
{: .notice--info}

## Summarizing the facts

As you read above CIKit has undergone significant changes, as in design as in implementations until the moment of getting the new license.

The idea of the software of this kind is not patented and could not be - you can do your own continuous integration programs as well as image editors, browsers etc.

Anybody, who still have doubts about the difference between CIKit and CIBox, may take the repositories and use `diff` command line utility for comparing the codebase at various stages of history.

## Why is it happening?

Unfortunately, somewhere in the beginning-middle of December 2017, [I made a mistake on Facebook](https://www.facebook.com/alwayswannarock/posts/1217151198417062) that touches a politically-unstable topic in Ukraine. A bit later [I was blocked in Drupal Ukraine community](https://www.facebook.com/groups/drupal.ua/permalink/10155789972390218) on Facebook [by Andrii Podanenko](https://www.facebook.com/groups/drupal.ua/permalink/10155793859410218); I have never read and even seen such a lot of rudeness about myself. A single man has started and, it seems, many others were just waiting until the dam breaks: they immediately picked up a wave of personalized insults.

I do understand that *my post was an absolute mistake* and **I want to apologize** here once again, apart from [couple times](https://www.facebook.com/alwayswannarock/posts/1218211074977741) I already [did this](https://www.facebook.com/groups/drupal.ua/permalink/10155789972390218?comment_id=10155790653055218) on Facebook.

To make a complete picture of the situation you can check [the entire post and its comments](https://www.facebook.com/groups/drupal.ua/permalink/10155789972390218) on Facebook.

I have silently swallowed all personal affronts on Facebook but now it is a time to step in and stop tolerating the attempts to discredit me.

## Legal actions

On January 9, 2018, I had a legal consultation (the first time in a life) with [Axon Partners](http://axon.partners) (these guys leave a damn good impression) and we agreed to wait until January 18 (10 business days since the takedown notice), when Github should unblock the [CIKit](https://github.com/BR0kEN-/cikit). My personal desire is to forget all these disagreements and move on, but if Andrii Podanenko will not stop pursuing me, independently on a sphere of life, I will be forced to collect all the facts and go to court.

## Thank you

It was not easy to stay calm, passing through the streams of mud, but thank you - this made me stronger.

I never actively advertised the CIKit because had an oral agreement with Andrii Podanenko but now I can no longer consider its validity.
{: .notice--info}

I do appreciate everyone who took part in CIBox until the day I made the fork. Without your hard work I would not be able to create the CIKit. Precisely for this reason I did not initiate a new repository, perpetuating everyone involved [in a history](/about/#contributors).

As a final chord of this article, I want to say **thank you** to everyone who was supporting me these no-easy days. Without you, guys, I would be feeling *BR0kEN*.

Respect everyone!
