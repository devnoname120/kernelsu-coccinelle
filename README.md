# KernelSU Coccinelle

This repository contains semantic patches that can be used to apply so-called “manual” KernelSU hooks on a wide range of Android kernels without needing to do anything manually or fixing any conflicts. These patches are written in Coccinelle's excellent Semantic Patch Language (SmPL) which operates on the *code structure* rather unlike `diff` and `git diff`.

These patches are much more robust and universal than diffs. In addition to working on a wide range of kernel versions, they don't care about comments, spacing, crappy vendor kernel backports, most variable names, etc. The downside is that they are *much* harder to create and the documentation is sparse. Now, today is your lucky day because I already went through all the trouble myself so that you can stay blissfully unaware of how it actually works.

# Quick use

If you are too lazy to read anything then just go to your Android kernel directory and run this:

```sh
curl https://raw.githubusercontent.com/devnoname120/kernelsu-coccinelle/online/apply.sh | sh
```

# Hook types

There are two flavors of the patches needed to integrate KernelSU and its forks into your kernel:

## 1. [Classic hooks](https://github.com/devnoname120/kernelsu-coccinelle/tree/main/classic-hooks)

Those are a re-implementation of the OG “manual hooks” as semantic patches with some additional required backports. These are the most basic and have the best compatibility with OG KernelSU* and its forks.

  👉 See [`classic-hooks/README.md`](classic-hooks/README.md).

## 2. [Scope-minimized hooks](https://github.com/devnoname120/kernelsu-coccinelle/tree/main/scope-minimized-hooks)

These hooks are mostly based on [@backslashxx](https://github.com/backslashxx)'s scope-minimized hooks v1.3 + ultra-legacy + lots of backports + I read an insane number of vendor custom Android kernel sources to properly handle all cases and their quirks.

Use these if your kernel version is not supported by the `classic-hooks` or if you like to live dangerously. Note that these are *not* supported by OG KSU best used in combination with [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next) as other forks may miss some of the commits that are required for the scope-minimized hooks to work.

👉 See [`scope-minimized-hooks/README.md`](scope-minimized-hooks/README.md).


# How to learn Coccinelle

**Introduction**:
- EJCP 2018 conference:
  - [Introduction to Coccinelle Part 1](https://ejcp2018.sciencesconf.org/file/part1_lawall.pdf) ([archive](https://web.archive.org/web/20250518120845/https://ejcp2018.sciencesconf.org/file/part1_lawall.pdf))
  - [Introduction to Coccinelle Part 2](https://ejcp2018.sciencesconf.org/file/part2_lawall.pdf) ([archive](https://web.archive.org/web/20250518120846/https://ejcp2018.sciencesconf.org/file/part2_lawall.pdf))
- [Introduction to Semantic Patching of C programs with Coccinelle](https://web.archive.org/web/20250207160114if_/https://www.lrz.de/services/compute/courses/x_lecturenotes/hspc1w19.pdf#page=21)
- [Semantic patching with Coccinelle](https://lwn.net/Articles/315686/) (LWN)
- [Evolutionary development of a semantic patch using Coccinelle](https://lwn.net/Articles/380835/) (LWN)
- [Coccinelle for the newbie](https://home.regit.org/technical-articles/coccinelle-for-the-newbie/)
- [Advanced SmPL: Finding Missing IS ERR tests](https://coccinelle.gitlabpages.inria.fr/website/papers/cocciwk4_talk2.pdf) ([archive](https://web.archive.org/web/20250518130934/https://coccinelle.gitlabpages.inria.fr/website/papers/cocciwk4_talk2.pdf))


**Documentation**:
- Cheatsheet: https://zenodo.org/records/14728559/files/coccinelle_cheat_sheet_20250123.pdf
- Cookbook: https://github.com/kees/kernel-tools/tree/trunk/coccinelle
- Grammar reference: https://coccinelle.gitlabpages.inria.fr/website/docs/main_grammar.html ([pdf](https://coccinelle.gitlabpages.inria.fr/website/docs/main_grammar.pdf))
- Standard isomorphisms: https://coccinelle.gitlabpages.inria.fr/website/standard.iso.html

**Examples**:
- https://github.com/groeck/coccinelle-patches
- https://coccinelle.gitlabpages.inria.fr/website/sp.html
- https://coccinelle.gitlabpages.inria.fr/website/rules/
- https://github.com/coccinelle/coccinellery
- More examples: https://github.com/search?q=language%3ASmPL&type=code

**Mailing lists**:
- cocci@systeme.lip6.fr (search the [[archives]](https://lore.kernel.org/cocci/))
- cocci@inria.fr (search the [[archives]](https://lore.kernel.org/cocci/))

**GitHub repository**: https://github.com/coccinelle/coccinelle
