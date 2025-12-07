---
title: "AI Experiments for Frontend, SEO and UI Design"
description: "I rebuilt small projects to test AI for frontend, SEO and UI. Here’s what helped, what broke, and how I’d use it again."
summary: "I rebuilt small projects to test AI for frontend, SEO and UI. Here’s what helped, what broke, and how I’d use it again."
date: 2025-12-01T05:00:00+00:00
tags: ["ai", "frontend", "seo"]
author: "Me"
draft: false
---

I’ve never been the biggest fan of AI. I’ve mostly used it for autocompletion in editors. Handy, but not central to how I work. Over the past few months I rebuilt a few personal R&D projects to see what current tools can actually do, with a focus on SEO, frontend and UI quality.

My setup was simple: ChatGPT for content, Copilot for code and design. I went in skeptical and came out more impressed, with caveats.

## TL;DR

- Good for UI exploration and getting unstuck. Set constraints and iterate.
- Struggles with CSS at scale. Tailwind helps keep things tidy.
- Small, composable components work best.
- Fine for SEO first drafts, but still needs a proper edit.
- Next up: Magento, MCP or RAG with real signals (Sentry/NewRelic), and focused tools like Claude and Cursor.

## What worked well

### UI design with guidance
With clear constraints, AI produced decent UI patterns. It was strongest at:
- Generating 2–3 small variations for a component and iterating quickly in natural language.
- Referencing live sites for design inspiration (layout, structure, styling, element hierarchy).
- Filling gaps when I wasn’t sure what should go in a section - propose options, then tighten with follow-up prompts.

If your CSS skills peaked at Comic Sans, this helps. It won’t replace a designer, but it’s good enough.

### Utility-first CSS keeps it honest (and your sanity)
Raw CSS from AI tends to be additive. It rarely removes rules and drifts into spaghetti, very quickly. With overlapping selectors, magic numbers and redundant declarations. Tailwind, or similar utility based approaches, reins this in:
- Pushes styling decisions into class-level tokens rather than scattered CSS files.
- Encourages small, focused components with clear boundaries.
- Makes refactors and deletions obvious, because you change the component markup rather than hunting selectors.

### Small components = better results (fewer tears)
Keep prompts scoped to a single component or tiny feature. Break design into small parts, iterate per component, then stitch together.


### CSS maintenance and refactors
AI is poor at maintaining CSS. Ask for changes and it adds more. Over time this gets hard to reason about and expensive to maintain. The fix is process based:
- Use utility CSS.
- Keep components small.
- Regularly delete and regenerate, rather than endlessly patching.


## SEO and content generation
I tested AI for generating SEO friendly copy and page structure. It’s better than I expected at:
- Creating headings, summaries, meta descriptions, and internal link suggestions.
- Suggesting semantic structure (sections, lists, FAQs) that map well to search intent.
- Producing readable first drafts that are easy to edit.

But it still is not a replacement for human editing. And requires careful review for:
- Accuracy and claims.
- Tone consistency (UK English, pragmatic, no fluff).
- Internal linking relevance to your actual site content.

It won’t magically outrank everyone, but from experience, it does outrank most if used right 😉

## Tooling used
- ChatGPT for content and outlines.
- Copilot for code and design iteration.

This mix was a decent balance: rapid ideation with constrained implementation.

## Next experiments
- Magento: explore AI for module scaffolding, boilerplate UI components, and Page Builder component generation. Also test where it falls over, like theme layer CSS or Plugin / Observer logic.
- MCP servers or RAG: pull structured context from docs, error context from Sentry and New Relic.
- Dedicated tools: Claude and Cursor have good reviews. Be interesting to see the USPs over Copilot.
- UI mockups: look at tools that can generate a handful of full mockups with different styles and layouts. Pick one, then use Copilot to turn it into functional markup.

## Final thoughts (still a healthy dose of skepticism)
I started out skeptical and still am in parts. Used deliberately, AI is a useful accelerant:
- Great at ideation and exploration. Especially for MVPs.
- Decent at implementation when tightly scoped.
- Poor at long term CSS maintenance unless you constrain it.

---

Note: This post was drafted and edited with help from Copilot.
