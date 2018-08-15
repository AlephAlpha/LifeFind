# LifeFind
A simple and naïve Game of Life pattern searcher written in Wolfram Language.

## 用法

这是个 Mathematica 包。[安装](http://support.wolfram.com/kb/5648)了之后，在 Mathematica 中用以下命令来加载：

```Mathematica
Needs["Life`"]
```

包里用来搜索图样的函数是 `SearchPattern` 和 `LifeFind`。用法都一样，区别在于 `SearchPattern` 输出的是一个数组，而 `LifeFind` 输出的是图片，还顺带打印出图样的 [RLE](http://www.conwaylife.com/wiki/Run_Length_Encoded)。

![截图](Screenshot.png)

`LifeFind[x, y, p, dx, dy]` 搜索的是大小不超过 `(x, y)`，周期为 `p`，每个周期平移 `(dx, dy)` 的图样。比如说，`LifeFind[5, 16, 3, 1, 0]` 搜索的是大小不超过 5×16 的 c/3 的竖直方向的飞船。

可以省略 `dx` 和 `dy`，此时默认 `dx` 和 `dy` 都是 0，也就是说搜索的是静物或者振荡子。如果连 `p` 也省略，则默认 `p` 是 1，也就是说搜索的是静物。

还可以设置 `"Rule"` 和 `"Symmetry"` 两个参数，来设定规则和对称性。

目前仅支持 [totalistic](http://conwaylife.com/wiki/Totalistic_Life-like_cellular_automaton) 或者 [isotropic non-totalistic](http://conwaylife.com/wiki/Isotropic_non-totalistic_Life-like_cellular_automaton) 的 Life-like 的规则，规则的写法见 [Golly 的帮助文件](http://golly.sourceforge.net/Help/Algorithms/QuickLife.html)。不支持 B0 的规则，也不支持六边形的或者 [von Neumann 邻域](http://conwaylife.com/wiki/Von_Neumann_neighbourhood)的规则。

支持的对称性包括 "C1"，"C2"，"C4"，"D2-"，"D2\\\\"，"D2|"，"D2/"，"D4+"，"D4X"，"D8"。这些对称性的写法是我从 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search) 抄来的，具体的说明见[这里](http://www.conwaylife.com/wiki/Symmetry)，"D2" 和 "D4" 后面的符号表示它的对称轴。

除了 `SearchPattern` 和 `LifeFind`，这个包里还有以下几个函数：

* `RuleNumber`: 把一个规则转写成一个大数字，可以用在 Mathematica 的 [`CellularAutomaton`](https://reference.wolfram.com/language/ref/CellularAutomaton.html) 函数中。
* `ToRLE`: 把一个数组转换成 RLE 格式。
* `FromRLE`: 把 RLE 转换成一个数组。
* `FromAPGCode`: 把 apgcode 转换成一个数组。

这几个转换的函数都只支持两种状态的规则，也就是说，那个数组只有 0 和 1。

这个包就是写着玩的搜索速度慢得离谱。如果要实用一点的搜索工具，请见下表：

| 名称 | 作者 | 搜索方式 | 编程语言 | 平台 | 网址 | 备注 |
| -- | -- | -- | -- | -- | -- | -- |
| [apgsearch](http://conwaylife.com/wiki/Apgsearch) (2.0 以上版本) | Adam P. Goucher | 汤 | C++ | 64 位 Linux | [GitLab](https://gitlab.com/apgoucher/apgmera) | |
| [apgsearch](http://conwaylife.com/wiki/Apgsearch) (1.x 版) | Adam P. Goucher | 汤 | Python | Golly 脚本 | [Catagolue](https://gol.hatsya.co.uk/apgsearch) | |
| [ikpx](http://conwaylife.com/wiki/Ikpx) | Adam P. Goucher | [SAT 问题](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem) | Python | 跨平台 | [GitLab](https://gitlab.com/apgoucher/metasat) | 自带一个叫 MetaSAT 的 SAT Solver |
| [Logic Life Search](http://conwaylife.com/wiki/Logic_Life_Search) | Oscar Cunningham | [SAT 问题](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem) | Python | 号称跨平台（Windows 下需要 Cygwin） | [GitHub](https://github.com/OscarCunningham/logic-life-search) | 需要自备 SAT Solver |
| [gfind](http://conwaylife.com/wiki/Gfind) | David Eppstein | 见[相关论文](http://arxiv.org/abs/cs.AI/0004003) | C | 跨平台 | [代码](https://www.ics.uci.edu/~eppstein/ca/gfind.c) | 专搜飞船 |
| gsearch | David Eppstein | 给定范围里的暴力搜索 | C | 跨平台 | [代码](https://www.ics.uci.edu/~eppstein/ca/gsearch.c) | 很慢 |
| ofind | David Eppstein | 类似于gfind | C | 跨平台 | [代码](https://www.ics.uci.edu/~eppstein/ca/ofind.c) | 专搜振荡子 |
| [lifesrc](http://conwaylife.com/wiki/Lifesrc) | David Bell | Dean Hickerson 发明的算法 | C | 跨平台 | [代码](http://members.tip.net.au/%7Edbell/programs/lifesrc-3.8.tar.gz) | |
| [JavaLifeSearch](http://conwaylife.com/wiki/JavaLifeSearch) | Karel Suhajda | 同 lifesrc | Java | 跨平台 | [帖子](http://conwaylife.com/forums/viewtopic.php?f=9&t=990) | lifesrc 的 Java 版 |
| [WinLifeSearch](http://conwaylife.com/wiki/WinLifeSearch) | Jason Summers | 同 lifesrc | C | Windows | [官网](http://entropymine.com/wls/) | lifesrc 的 Windows（图形界面）版 |
| [catalyst](http://conwaylife.com/wiki/Catalyst_(search_program)) | Gabriel Nivasch | 静物与给定图样的反应 | C++ | 跨平台 | [代码](http://www.gabrielnivasch.org/fun/life/catalyst_v10.zip?attredirects=0) | 参见[催化](http://conwaylife.com/wiki/Catalyst) |
| Random Agar | Gabriel Nivasch | 类似于汤 | C++ | 跨平台 | [代码](http://www.gabrielnivasch.org/fun/life/) | 专搜琼脂 |
