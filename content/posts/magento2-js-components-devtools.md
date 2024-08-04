---
title: "How to debug Magento Javascript components in DevTools"
description: ""
date: 2024-08-08T05:00:00+00:00
tags: ["magento2", "javascript"]
author: "Me"
draft: false
---
Often when debugging frontend functionality, I find myself reaching for access into Magento Javascript components. To either read the current state or invoke various methods within that component to test return values. But how do we do this? How do we get, lets say, the current quote?

It's quite simple really, we just call `require` instead of `define` like we would in a component. Slap a `debugger` call in the body and now you can play with that component to your hearts content.
```js
require(['Magento_Checkout/js/model/quote'], function(quote) {
    debugger;
})
```

Whilst there is nothing stopping you using the same approach in a PHTML template, for production code. 100% of the time, there is a better way. So spend the extra time and do it properly. Although it can come in handy for a temporary hotfix (not speaking from experience at all).