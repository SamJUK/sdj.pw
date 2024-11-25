---
title: "Finding Magento 2 Uncacheable Blocks"
description: "Quick and easily identify what XML blocks are breaking your full page caching, by injecting a small piece of code into any template."
date: 2023-02-17T11:30:00+00:00
tags: ["magento2", "debugging"]
author: "Me"
draft: false
documentation: https://docs.sdj.pw/magento/non-cacheable-blocks.html
---
A handful of times I have came across pages where full page caching is broken. Instead of diving through and grepping various XML files to identify what module is breaking the cache. I have wrote a section of code, that will identify any uncacheable blocks on the current page and display them in the bottom left of the page.

![Image of the uncachable blocks DOM element the code snippet adds](/images/uncacheable-blocks.jpg)

Currently I just paste this into the theme (usually the header or logo phtml files). Although I plan to release this within a more in-depth composer module that also offers a host of other debug related functionality in the future.

```php
<?php
    // @START: Non cacheable Block Identification
    $layout = $this->getLayout();
    $r = new ReflectionMethod(get_class($layout), 'getXml');
    $r->setAccessible(true);
    $xml = $r->invoke($layout);
    $ncb = $xml->xpath('//' . \Magento\Framework\View\Layout\Element::TYPE_BLOCK . '[@cacheable="false"]');
    $cnt = count($ncb);
    echo '<div style="position: fixed;bottom: 0;left: 0;z-index: 72349872398457982374982374897239847239847923742374;background: #eaeaea;padding: 20px;border: 2px solid #00000042;color: black;">';
    echo "<h2 style='font-size: 24px;font-weight: bold;color: #000000e3;border-bottom: 1px solid #0000002b;margin-bottom: 10px;'>$cnt Uncachable Blocks</h2>";
    foreach($ncb as $b) {
        echo "<p style='margin-bottom: 0;'>{$b->getBlockName()}</p>";
    }
    echo '</div>';
    // @END: Non cacheable Block Identification
?>
```
