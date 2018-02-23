# Elm playground

This repo contains code and notes from my February 2018 learning day under the GraphQL topic. A learning day is a day-a-month event here at [Evermade](https://www.evermade.fi) where each developer can pick a topic of their interest and spend a full day on learning the technology as they best see fit. The only requirement is that the developer produces enough notes and code to be able to share their learnings onwards to fellow developers and co-workers.

## What is Elm?

Elm is a functional, statically typed programming language. It is first and foremost intended for producing web front-ends, and so it compiles down to HTML and JavaScript.

What primarily makes Elm stand out from every other JS tool is that the compiler can guarantee **no runtime errors in practice**. While you can force the code to produce errors (e.g. by calling `Debug.crash`), in practice you should be able to be certain that if the code compiles, it will not run into errors in your browser.

Other features of Elm include:
- No `null` or `undefined`, everything has to be explicitly handled
- No side effects, which leads to very predictable code
- Immutable data types, further contributing to safety
- Strong static typing, ensuring there are no silly type coercion bugs
- Custom types & pattern matching, allows you to model problems clearly
- Advanced tooling, such as the `time travel debugger`
- Built in framework, known as the `Elm architecture` (which inspired Redux)
- **Crazy great error messages**, the compiler is the most helpful buddy ever

## Who uses Elm?

While powerful and solving real problems, Elm is not a very popular language. Some reasons for this could be a) that it is built with Haskell so being able to contribute back to the core requires Haskell knowledge, and b) it differs very much from almost every other language in the JavaScript ecosystem, so the initial learning takes longer.

A quick look at the users of Elm includes names like Pivotal (the tracker & others), NoRedInk ([200 000+ lines of production Elm code with a single runtime error due to their own mishap](https://twitter.com/rtfeldman/status/961051166783213570)).

## Drawbacks of Elm

- Writing HTML as functions feels painful
- Largely a one-man-show with a BDFL (Benevolent dictator for life). Keeps things consistent but also locks the language up
- JSON parsing, a very common task in everyday web apps, is quite annoying
- Small community and package ecosystem, slow development cycles
