---
title: Method level caching
translationCs: /v3/blog/2016/07/01/method-level-caching.html
---

There is a funny word in my native Czech language which I like a lot - "kurvítko" (kur-veet-ko; loose translation: "screwed-up component"). Although colloquial and a bit vulgar, to me it has the same meaning as what would otherwise take me a long time to explain. It is a component that is rather insignificant within the greater whole but that can, at the same time, actually mess up such a greater whole in a major way. The world is not black and white and so when talking about components, it is better to use the term "kurvítko index", which expresses the ratio between the mentioned properties. I have assigned my own internal "kurvítko index" to various development practices and this index influences my architectonic decisions to a great extent. Do you know what to me has the biggest "kurvítko index"? Without any doubt, it is Caching and High Availability.
 
There is nothing wrong with caching as such. As long as it was applied in software to a clearly defined domain, such as the caching of entire HTML pages, it was OK. However, caching tools have gradually become more generalized and [tools applying caching in the form of meta information on the level of individual functions/methods have even appeared in the mainstream][Spring:cache]. Greater generality and granularity of caching have not fundamentally changed anything but there are many downsides of caching that become much more apparent and are much harder to deal with than in domain-specific caching. I will thus speak specifically about caching on the method level because it is easier to explain although it also concerns caching in general to a certain extent.
 
## There is no such thing as a free lunch

It seems simple at the first glance: Do you have a problem with performance? Don't waste time - simply make a few selected methods @Cacheable and move on. This is exactly how caching is seen by project management and this is exactly what architect training sessions for the rest of the team look like. The initial perception of all those involved that caching is a "free lunch" in terms of performance is a major factor in the size of the "kurvítko index". People typically find out that there is a problem only when that (undetected) problem sneaks into production.
 
Let’s examine the benefits first. For a cache to actually be useful, it must be properly set, which requires long-term teamwork of both the development and operations teams. Developers first decide which data is to be inserted into which caches and how it will be handled; the operations team sets the parameters of the delivered caches according to the hardware, load profiles, system configuration and monitoring of real behavior. Altogether it is a kind of ["black magic"][Pinos:cache] for which one activity depends on the other activity in the loop but it is typically not resolved in technical design or on the management level (because setting @Cacheable in place is enough, right?).
 
Moreover, in most large companies, the relations between development and operations are far from ideal and at times can verge on trench warfare. Applications thus often end in production with "best guess" default parameters from developers and the operations team does not want to deal with the situation because they consider it as application settings and that is not their business. If I say that the results of such caching are catastrophic, I am not talking about the small percentage of expected cost savings but about the fact that the resulting performance effect can be negative! Runtime cache costs do not necessarily have to be small; this is explained below.
 
## Keys, keys, keys

If the complexity of the entire process is underestimated, the benefits can be ridiculously few. What problems can caching bring? All the main problems revolve around one topic - key generation for cached items.
 
For someone using common sense, the explanation that keys are calculated from parameters of a cached method in a similar manner as hash into hash map is sufficient. Someone with more experience will possibly verify that the method name is also included in the hash, otherwise the same result would be returned from any cached method with the same signature. For certain frameworks, [such absurd behavior is still default][ehcache-annotations].
 
The method name is not a fail-safe method to ensure key uniqueness either; see typical DAO method names for various entities such as getById(long id), etc. Wouldn't it thus be enough to add the class name by default to the hash? That is not default behavior in any framework but even that may not be enough - what if the method is based on an abstract generic ancestor (which is typical e.g. for DAO implemented by means of JPA)?
 
There are many scenarios (banal but real) that one can think of. However, I will not go into much detail here because these errors constitute a minor problem. If they occur, they are mostly explicit (class cast exception); they occur mainly consistently and are therefore caught during development and the particular cases can be directly resolved.
 
The main problem is that a cache does not have to be a hash map. A hash map uses hash only to define the position at which to find a record; the final selection is made by means of the equals method. Cache does not have to do this; paradoxically, only primitive in memory implementations can take that liberty. For the more professional however, absolute identification is the key. Why should you be interested in this? Most hash algorithm implementations do not handle collisions (even though they should; see below) and sacrifice collision resistance for speed.  If you were thus far unaware of this and are in doubt, an [example is a hash algorithm for a simple String in older Java][Java String]. Limitation to 16 characters does not seem completely secure, right? Such glaring cases have been corrected but more subtle cases remain.
 
It is good, and not only for these reasons, not to automatically rely on a [default key generator][Spring:default] but rather to select an appropriate combination of generator and cache implementation for which the priority does not have to be speed (sic!) but rather collision resistance. Collisions in this context constitute a complete catastrophe. An object for entirely different parameters may be returned from the cached method!
 
If, for example, a service method is being cached for which authorization for the given data is checked within, a collision of the key of the cached item circumvents this security measure. At first glance, this is only empty calamity-howling because keys are long and generating algorithms are sophisticated enough so that the possibility of a random collision is nonsensical; however, I would like to return to my comment that standard algorithms should not be too naive either.
 
Even though on the face of it a hash map is resistant to key collisions, in practice [such a collision is the basis for a denial-of-service attack][funkcionalne.cz:hash]. With this in mind, try to imagine the effort an attacker would have to make to detect collisions when the payoff would not be simply service stoppage but data theft. You may believe that a hash algorithm has quality in the sense of random collisions but does it have cryptographic quality? I cannot verify that and do not know of anyone who could.
 
Not having a math genius on the team, it is better to verify in code review that only the necessary data quantity from parameters is included in the key and none of them can be affected by the user. A good preventive measure against user data leakage is a custom key generator extension that will prefix the keys with the identifier of the logged-in user so that it is not possible for collision for data caches of two different users to occur.
 
So in summary, method level caching allows any programmer in any program location to circumvent all programming security tools, from a compiler through to a security audit. It can be a consequence of improper usage, bad settings, a random data constellation or a targeted attack. At best, a fatal error will occur; at worst, the application will inconspicuously dispense data. It should now be completely clear why caching can be compared to a live grenade in a pile of children's toys. And what I've described above is only the tip of the iceberg.
 
## State

I will try to set my paranoia to the side for a moment and talk a bit about the software-engineering aspect of a cache. Impure languages should come with a warning with pictures of suicidal-looking burnt-out programmers with the caption: "Having a state causes dependencies, dependencies cause complexity, complexity kills." Experienced programmers bear this in mind and eliminate any non-essential state. Cache, however, works in the opposite direction - it introduces a default state where there was none.
 
Dependency makes it necessary to identify (during any data manipulation) the caches from which old records should be removed. The more data in a cache, the more locations have such dependency. The more complex data kept in the cache, the harder it is recognize whether such dependency exists and not forget about it.
 
This is a known and obvious problem so, similar to keys, we will have a look at the more hazardous consequences of cache as application state. Personally, I am fully aware of these consequences working for a financial institution that has a legal obligation to inform all involved in the same manner. If its web runs in a cluster, it must not happen that a person accessing one node obtains information any later than a person accessing another node, due to caching.
 
The logical step here is to use cache implementation with synchronization. [When UDP multicast between nodes is allowed, the state of their cache is synchronized.][ehcache:synchro] All caches will have the same content so everyone will have the same data. Simple.
 
However, I have not described anything less here than one of the most difficult problems in computer science - distributed system consistency. There is a [majority view that this problem cannot be resolved without compromises][cap] and that is why there is typically one monolithic database in the core of larger systems. If there are strict regulatory requirements for the system, it is necessary to know what compromises are made by the selected cache implementation, otherwise it could be risky to guarantee anything. That is the darker side of a newly introduced state.
 
## Minor issues

The following points are minor compared to the issues described above and are thus explained briefly:
 
- When using standard hashCode for key generation, a class often slips in among the parameters that does not override the hashCode, which effectively switches off caching (the hashCode is different for each instance).
- Similarly, it is possible to unintentionally switch off caching when an object of the java.util.Date type slips in among the parameters and a potentially meaningless item, such as the number of milliseconds, is included in the hashCode for this object. This is often unintentionally initialized with a random current value and very few people reset after items have been set.
- Regarding the number of problems with hashCode use, several frameworks have their default key generator based on reflection. This however brings a specific set of problems, e.g. loops in an object graph or blacklists.
- It is dangerous to place the Cacheable annotation to class because it may lead to unintended method caching.
- If there are multiple annotations in a method, it is necessary to know the order in which the relevant proxy will be created. I have mentioned the security consequences when authorization is checked during cache although Transactional is interesting as well. It can start a transaction even though a cached value will be returned, meaning that any benefit of the cache will be negated.

## Uff...

Don't get me wrong - a cache that is sensibly used is a very useful tool and has therefore been [standardized][jsr-107]. For values that have been set on a one-off basis, such as application configuration or code lists, its use is truly simple and secure. That said, I wanted to point out what a mistake it would be to consider it an unearned silver bullet for performance, which is often the case.

[jsr-107]: https://jcp.org/en/jsr/detail?id=107
[cap]: https://en.wikipedia.org/wiki/CAP_theorem
[ehcache:synchro]: http://www.ehcache.org/documentation/2.8/replication/jgroups-replicated-caching.html#example-configuration-using-udp-multicast
[Pinos:cache]: http://tom2ee.blogspot.cz/2015/11/jak-se-vyplati-kesovani.html
[Java String]: https://en.wikipedia.org/wiki/Java_hashCode%28%29
[funkcionalne.cz:hash]: http://funkcionalne.cz/2016/02/kolize-hashu-pro-mirne-pokrocile/
[Spring:default]: https://github.com/spring-projects/spring-framework/blob/master/spring-context/src/main/java/org/springframework/cache/interceptor/DefaultKeyGenerator.java
[Spring:cache]: http://docs.spring.io/spring/docs/current/spring-framework-reference/html/cache.html
[ehcache-annotations]: https://code.google.com/archive/p/ehcache-spring-annotations/
[calavera.info:funkcionalni]: http://calavera.info/v3/blog/2016/04/24/objektove-vs-funkcionalni.html
[jsr-107]: https://jcp.org/en/jsr/detail?id=107
