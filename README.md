# [LifeFind](https://github.com/AlephAlpha/LifeFind)
A simple and naïve Game of Life pattern searcher written in Wolfram Language.

---

这是个用来搜索生命游戏（以及别的 Life-like 的元胞自动机）里的图样的 Mathematica 包。搜索方式是把图样要满足的条件看成一个 [SAT 问题](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem)，然后用 Mathematica 自带的 [`SatisfiabilityInstances`](http://reference.wolfram.com/language/ref/SatisfiabilityInstances.html) 函数求解。

这个包就是写着玩的，搜索速度慢得离谱。如果需要实用一点的搜索工具，推荐使用 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search)，或者见[《生命游戏搜索程序汇总》](https://www.jianshu.com/p/81c90ba597ea)。

### 下载与安装

直接点 Github 页面右上角的那个绿色的按钮 “Clone or download”就能下载。也可以用 `git clone`：

```bash
git clone https://github.com/AlephAlpha/LifeFind.git
```

安装的方式见[这里](http://support.wolfram.com/kb/5648)。

安装了之后，在 Mathematica 中用以下命令来加载：

```Mathematica
Needs["Life`"]
```

或者：

```Mathematica
<< Life`
```

### 用法

![截图](Screenshot.png)

包里用来搜索图样的函数是 `SearchPattern` 和 `LifeFind`。用法都一样，区别在于 `SearchPattern` 输出的是一个数组，而 `LifeFind` 输出的是图片，还顺带打印出图样的 [RLE](http://www.conwaylife.com/wiki/Run_Length_Encoded)。

`LifeFind[x, y, p, dx, dy]` 搜索的是大小不超过 `(x, y)`，周期为 `p`，每个周期平移 `(dx, dy)` 的图样。比如说，要搜索大小不超过 5×16，速度为 c/3 的竖直方向的飞船，只需要：

```Mathematica
LifeFind[5, 16, 3, 1, 0]
```

可以省略 `dx` 和 `dy`，此时默认 `dx` 和 `dy` 都是 0，也就是说搜索的是静物或者振荡子。如果连 `p` 也省略，则默认周期是 1，也就是说搜索的是静物。

还可以设置 `"Rule"`、`"Symmetry"`、`"Agar"`、`"Random"` 四个选项。

`"Rule"` 表示搜索的规则。目前仅支持 [totalistic](http://conwaylife.com/wiki/Totalistic_Life-like_cellular_automaton) 或者 [isotropic non-totalistic](http://conwaylife.com/wiki/Isotropic_non-totalistic_Life-like_cellular_automaton) 的 Life-like 的规则，规则的写法见 [Golly 的帮助文件](http://golly.sourceforge.net/Help/Algorithms/QuickLife.html)。不支持六边形的规则，也不支持后面加 `V` 表示冯·诺依曼邻域的写法。

`"Symmetry"` 表示搜索的对称性。支持的对称性包括 "C1"，"C2"，"C4"，"D2-"，"D2\\\\"，"D2|"，"D2/"，"D4+"，"D4X"，"D8"。这些对称性的写法是我从 [Logic Life Search](https://github.com/OscarCunningham/logic-life-search) 抄来的，具体的说明见[这里](http://www.conwaylife.com/wiki/Symmetry)，"D2" 和 "D4" 后面的符号代表它的对称轴。

`"Agar"` 选项默认为 `False`。当设为 `True` 时，搜索的是[琼脂](http://www.conwaylife.com/wiki/Agar)，而非有限的图样。

`SearchPattern` 和 `LifeFind` 默认会返回随机的结果，这是通过搜索的时候给要搜索的数组异或上一个随机数组得到的。如果不需要随机的结果，可以把 `"Random"` 选项设成是 1，此时异或上的数组取成全部是 1；也可以把 `"Random"` 选项设成是 0，此时异或上的数组取成全部是 0，不过搜索结果一般也全是 0，不建议使用。

### 其他函数

除了 `SearchPattern` 和 `LifeFind`，这个包里还有以下几个函数：

* `RuleNumber`: 把一个规则转写成一个大数字，可以用在 Mathematica 的 [`CellularAutomaton`](https://reference.wolfram.com/language/ref/CellularAutomaton.html) 函数中。只支持前面说的那些规则。
* `ToRLE`: 把一个数组转换成 [RLE](http://www.conwaylife.com/wiki/Run_Length_Encoded) 格式。可以设置 `"Rule"` 选项。只支持两种状态的规则，也就是说，数组只能由 0 和 1 组成。
* `FromRLE`: 把 RLE 转换成一个数组。只支持两种状态的规则。
* `FromAPGCode`: 把 [apgcode](http://www.conwaylife.com/wiki/Apgcode) 转换成一个数组。只支持两种状态的规则。
* `Parent`: 尝试搜索图样的[父母](http://www.conwaylife.com/wiki/Parent)。`Parent[pattern, m]` 表示在比原来的图样大 `m` 圈的范围内搜索；省略 `m` 时默认 `m` 是 0。搜索范围有限，搜不出结果不能说明这个图样是[伊甸园](http://www.conwaylife.com/wiki/Garden_of_Eden)。可以设置 `"Rule"` 选项。
* `ExportGIF`: 把一个图样导出成 GIF 文件。用法是 `ExportGIF[file, pattern, gen]`，这里 `file`、`pattern`、`gen` 分别为要导出到的文件名、图样（一个数组）、绘制的代数。可以设置 `"Rule"` 和 `"DisplayDurations"` 两个选项。

此外还定义了一个符号 `$Rule`，表示全局的默认规则。它的默认值是 `"B3/S23"`（生命游戏）。可以更改它的值，这样使用别的函数的时候就不必再设置 `"Rule"` 选项。
