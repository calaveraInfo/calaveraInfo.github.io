---
title: On software engineering
translationCs: /v3/blog/2016/10/05/o-softwarovem-inzenyrstvi.html
---

I have found it! I have finally found a tagline for my blog! I've been desperately looking for it since I created my homepage on Geocities a long time ago.‎ Others have used funny jokes, clever puns or motivating quotes, but I've felt ‎it has to be more profound. That place in the header deserves more, ideally personal mission statement and the meaning of life at once. But finding a tagline with such attributes in current world is as impossible as finding an original t-shirt in China export. Although my social network profiles begged for a tagline, they remained empty. Until now.
This is it: *Abstractions, contracts, dependencies.*

Why? Because I want to scream on the whole world that building a software is incredibly easy. How is it possible that [it blows up][fails] so often then?‎ Because there are horribly few people who can see what those easy principles of software engineering are.

I have learned to hide it, but I scream inside whenever‎ I hear the heated debates about which language is more expressive, which IDE is more integrated, which build tool faster, which architecture more scalable or which methodology more productive. Whenever someone uses KISS [or][abstraction tweet] [DRY][dry] [principle][repeat tweet] or some other jewell of the dev folk philosophy. Whenewer someone presents a new technology as a [silver bullet][silver] without being able to tell the essential problems of building a software which are exactly the same today as they were 40 years ago.

Round and round I see the naive expectation that some problem inherent to some goal, directly or indirectly, can be made significantly easier by some technology. It's a cargo cult, hoarding technologies in an expectation of luring a magical solution for the problem. But any software solution is in fact just an immaterial though and as such it can be simplified by only one thing - *abstraction*. Any technology is just it's medium, it doesn't deliver anything on itself, especially if it is used by a programmer who don't understand the concept of abstraction (which is the definition of a pejorative meaning of the word "coder" for me).

There is another cofails] so often then?‎ Because there are horribly few people who can see what those easy principles of software engineering are.

I have learned to hide it, but I scream inside whenever‎ I hear the heated debates about which language is more expressive, which IDE is more integrated, which build tool faster, which architecture more scalable or which methodology more productive. Whenever someone uses KISS [or][abstraction tweet] [DRY][dry] [principle][repeat tweet] or some other jewell of the dev folk philosophy. Whenewer someone presents a new technology as a [silver bullet][silver] without being able to tell the essential problems of building a software which are exactly the same today as they were 40 years ago.

Round and round I see the naive expectation that some problem inherent to some goal, directly or indirectly, can be made significantly easier by some technology. It's a cargo cult, hoarding technologies in an expectation of luring a mncept resurfacing all over again, that having less fixed plans is required for greater flexibility. It's popularity is the result of fundamental misunderstanding of the agile philosophy. As if we should use a jelly instead of bricks for a more earthquake resistant buildings. But the art of absorbing a change lies not in a vague design where everything is flexible, it lies in design in which only the fundamental objective is fixed, but rigidly. That is an art of designing *contracts*. What defines the objective which must be fulfilled by the contract? Abstraction.

And the third word? I'll start with my [favorite definition of software architecture from Martin Fowler][fowler]: "Architecture is whatever is important. Important is what is hard to change." I would infer one more step in this line: hard to change is everything upon which something else *depends*.‎ That's why I consider software architecture to be mostly a synonym for "dependency management" - some dependencies are more flexible than other, some can be eliminated, some inverted. This, not some visionary leadership, should be a day-to-day goal of a software architect. What are his tools for tracking and manipulation with dependencies? Contracts.

It is important to do such work because the complexity of dependencies without active management naturally rises over time. [It can get so high that it's not possible to responsibly analyze an impact of even the slightest change][dependency hell]. If it gets to this point, software project is heading to dissaster or is at least ripe for a complete makeover. ‎[If we want our profession to keep it's engineering status][atlantic], it must be as rare as for example collapse of a bridge. That is a job of a software architect.

Those three words, their meaning and ability to practice it are my personal definition of software engineering. I was surprised by an amount of people who considers them as academic rubbish. And I was even more surprised that googling them together haven't brought any meaningful results.

And then I've realized that this is it! This is my tag line with all the features I want.

[dependency hell]: https://research.swtch.com/version-sat
[fails]: http://spectrum.ieee.org/static/the-staggering-impact-of-it-systems-gone-wrong
[dry]: http://thereignn.ghost.io/on-dry-and-the-cost-of-wrongful-abstractions/
[abstraction tweet]: https://twitter.com/jessitron/status/619941474902351872
[repeat tweet]: https://twitter.com/jezenthomas/status/776096875648847872
[silver]: http://worrydream.com/refs/Brooks-NoSilverBullet.pdf
[fowler]: http://martinfowler.com/ieeeSoftware/whoNeedsArchitect.pdf
[atlantic]: http://www.theatlantic.com/technology/archive/2015/11/programmers-should-not-call-themselves-engineers/414271/