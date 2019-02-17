# [LifeFind](https://github.com/AlephAlpha/LifeFind)
A simple and naïve Game of Life pattern searcher written in Wolfram Language.

![Screenshot](Screenshot.png)

这是个用来搜索生命游戏（以及别的 Life-like 的元胞自动机）里的图样的 Mathematica 包。搜索方式是把图样要满足的条件看成一个 [SAT 问题](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem)，然后用 Mathematica 自带的 [`SatisfiabilityInstances`](http://reference.wolfram.com/language/ref/SatisfiabilityInstances.html) 函数求解。这个包的灵感来自 Oscar Cunningham 写的 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search)。

这个包就是写着玩的，搜索速度慢得离谱，完全无法搜索周期稍大的图样。如果需要实用一点的搜索工具，推荐使用 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search)（可搜各种图样），或者 [ntzfind](https://github.com/rokicki/ntzfind)（专搜飞船）。更多搜索工具见[《生命游戏搜索程序汇总》](https://www.jianshu.com/p/81c90ba597ea)。

我不怎么懂编程，代码肯定有很多 bug。遇到问题欢迎来提 [issue](https://github.com/AlephAlpha/LifeFind/issues)。

具体的用法见 [Wiki](https://github.com/AlephAlpha/LifeFind/wiki)。
