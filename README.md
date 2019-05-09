# [LifeFind](https://github.com/AlephAlpha/LifeFind)

A simple and naïve Game of Life pattern searcher written in Wolfram Language.

![Screenshot](Screenshot.png)

这是个用来搜索生命游戏（以及别的 Life-like 的元胞自动机）里的图样的 Mathematica 包。搜索方式是把图样要满足的条件看成一个 [SAT 问题](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem)，然后用 Mathematica 自带的 [`SatisfiabilityInstances`](http://reference.wolfram.com/language/ref/SatisfiabilityInstances.html) 函数求解。灵感来自 Oscar Cunningham 写的 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search)。

这个包就是写着玩的，搜索速度慢得离谱，完全无法搜索周期稍大的图样。如果需要实用一点的搜索工具，推荐使用 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search)（可搜各种图样），或者 [ntzfind](https://github.com/rokicki/ntzfind)（专搜飞船）。更多搜索工具见[《生命游戏搜索程序汇总》](https://alephalpha.github.io/2018/08/10/%E7%94%9F%E5%91%BD%E6%B8%B8%E6%88%8F%E6%90%9C%E7%B4%A2%E7%A8%8B%E5%BA%8F%E6%B1%87%E6%80%BB/)。

我不怎么懂编程，代码肯定有很多 bug。遇到问题欢迎来提 [issue](https://github.com/AlephAlpha/LifeFind/issues)。

以下是简短的英文说明。详细的用法见[维基](https://github.com/AlephAlpha/LifeFind/wiki)（仅中文），或者[使用范例](https://alephalpha.github.io/2019/03/04/%E7%94%A8-Mathematica-%E6%90%9C%E7%B4%A2%E7%94%9F%E5%91%BD%E6%B8%B8%E6%88%8F%E4%B8%AD%E7%9A%84%E9%9D%99%E7%89%A9%EF%BC%88%E4%B8%89%EF%BC%89/)。

---

This is a Mathematica package for finding patterns in life-like cellular automata. Inspired by Oscar Cunningham's [Logic Life Search](https://github.com/OscarCunningham/logic-life-search), it converts the problem to a [SAT problem](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem), and solves it with the built-in function [`SatisfiabilityInstances`](http://reference.wolfram.com/language/ref/SatisfiabilityInstances.html).

## Usage

This is a Mathematica package, so you need [_Wolfram Mathematica_](http://www.wolfram.com/mathematica/). [Here](http://support.wolfram.com/kb/5648) is a installation guide for any Mathemaica packages.

After the installation, you can load the package with

``` mathematica
<< Life`
```

The main function in the package is `LifeFind`. `LifeFind[x, y, p, dx, dy]` will try to find a pattern with size `(x,y)`, period `p` (default = `1`), and translating `(dx,dy)` (default = `(0,0)`) during a period.

For example, this may find [25P3H1V0.1](http://conwaylife.com/wiki/25P3H1V0.1):

``` mathematica
LifeFind[5, 16, 3, 1, 0]
```

You can specify the rule and the [symmetry](http://www.conwaylife.com/wiki/Symmetry) with options `"Rule"` and `"Symmetry"` (see the screenshot above). The default rule is `"B3/S23"` (Conway's Game of Life). The supported symmetries are the same as Logic Life Search.

If you can read Chinese, please read the [Wiki](https://github.com/AlephAlpha/LifeFind/wiki) or these [usage examples](https://alephalpha.github.io/2019/03/04/%E7%94%A8-Mathematica-%E6%90%9C%E7%B4%A2%E7%94%9F%E5%91%BD%E6%B8%B8%E6%88%8F%E4%B8%AD%E7%9A%84%E9%9D%99%E7%89%A9%EF%BC%88%E4%B8%89%EF%BC%89/).

## Supported rules

* [Totalistic](http://conwaylife.com/wiki/Outer-totalistic_Life-like_cellular_automata) and [non-totalistic](http://conwaylife.com/wiki/Non-totalistic_Life-like_cellular_automaton) life-like rules
* Totalistic and non-totalistic [hexagonal](http://www.conwaylife.com/wiki/Hexagonal_neighbourhood) rules (hexagonal symmetries are _not_ supported)
* The corresponding [Generations](http://www.conwaylife.com/wiki/Generations) rules.

The output for Generations rules might be incomplete: there might be "dying" cells outside the bounding box. I will _not_ fix this.

If `"Rule"` is set to `""`, it will search in an unspecified rule, and return both the rule and the pattern. This is extremely slow, and the rule string is _not_ simplified.
