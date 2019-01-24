# [LifeFind](https://github.com/AlephAlpha/LifeFind)
A simple and naïve Game of Life pattern searcher written in Wolfram Language.

---

Translated by [Google](https://translate.google.com). Some obvious errors are fixed manually. If you have a better translation, feel free to send a pull request.

---

This is a Mathematica package for searching patterns in Conway's Game of Life (and other Life-like cellular automata). The search method is to treat the condition that the pattern needs to satisfy as a [SAT problem](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem), and then solve it with the [`SatisfiabilityInstances`](http://reference.wolfram.com/language/ref/SatisfiabilityInstances.html) function that comes with Mathematica.

This package is written for fun. The search speed is too slow, and it is impossible to search for a pattern with a slightly larger period. If you need a useful search tool, it is recommended to use [Logic Life Search](https://github.com/OscarCunningham/logic-life-search), or see [Game of Life Search Program Summary](https://www .jianshu.com/p/81c90ba597ea).

I don't know much about programming, and the code definitely has a lot of bugs. Please feel free to create [issues](https://github.com/AlephAlpha/LifeFind/issues).

## Download and installation

You can download it by clicking the green button "Clone or download" in the upper right corner of the Github page. You can also use `git clone`:

```bash
Git clone https://github.com/AlephAlpha/LifeFind.git
```

See [here](http://support.wolfram.com/kb/5648) for the installation guide.

Once installed, load it in Mathematica with the following command:

```Mathematica
Needs["Life`"]
```

or:

```Mathematica
<< Life`
```

## Searching patterns

![Screenshot](Screenshot.png)

The functions used to search for patterns in the package are `SearchPattern` and `LifeFind`. Their usage is the same. The difference is that `SearchPattern` outputs an array, and `LifeFind` outputs the image, and also prints the pattern's [RLE](http://www.conwaylife.com/wiki/Run_Length_Encoded).

`LifeFind[x, y, p, dx, dy]` searches for patterns whose size does not exceed `(x, y)`, whose period is `p`, and translates `(dx, dy)` every period. For example, to search for a spaceship with a size of no more than 5×16, a period of 3, and a speed of c/3, you only need to:

```Mathematica
LifeFind[5, 16, 3, 1, 0]
```

You can omit `dx` and `dy`, in which case the default `dx` and `dy` are both 0, which means that you are searching for stills or oscillators. If even `p` is omitted, the default period is 1, which means that the search is still.

Search results are random and the time required for the search is also very unstable. If the search time is too long, you can use `Alt+.` ( `Ctrl+C` on the command line interface) to interrupt.

You can also set the following options:

#### `"Rule"`

Represents the rules of the search. Currently only supports [totalistic](http://conwaylife.com/wiki/Totalistic_Life-like_cellular_automaton) or [isotropic non-totalistic](http://conwaylife.com/wiki/Isotropic_non-totalistic_Life-like_cellular_automaton) Life-like Rules. Rules are written in [Golly's help file](http://golly.sourceforge.net/Help/Algorithms/QuickLife.html). The hexagonal rules are not supported, and appending `V` to the von Neumann neighborhood is not supported.

#### `"Symmetry"`

Indicates the symmetry of the search. Supported symmetries include "C1", "C2", "C4", "D2-", "D2\\\\", "D2|", "D2/", "D4+", "D4X", "D8 ". The first two characters of symmetry represent the symmetry group of the pattern, and "Cn" and "Dn" represent [cyclic groups](https://en.wikipedia.org/wiki/Cyclic_group) and [dihedral groups](https: //en.wikipedia.org/wiki/Dihedral_group); The symbols after "D2" and "D4" represent the axis of symmetry of the pattern. These symmetry are copied from [Logic Life Search](https://github.com/OscarCunningham/logic-life-search). For details, see [here](http://www.conwaylife. Com/wiki/Symmetry).

#### `"Agar"`

This option defaults to `False`. When set to `True`, the search is an [agar](http://www.conwaylife.com/wiki/Agar) instead of a limited pattern. It can also be set to `{True, False}` or `{False, True}`, so that the searched pattern is limited in the vertical or horizontal direction and infinitely in the other direction.

#### `"Changing"`

This option defaults to `False`, but often outputs still lifes when searching for oscillators. When set to `True`, only the changing pattern will be searched, that is, the still life will be excluded; it can also be set to `{i, j}`, where `i` and `j` are two positive integers, when searching for a pattern different in the `i` generation and the `j` generation. For example, to search for an oscillator with a period of 4, you can set `"Changing" -> {1, 3}`. Note that setting this option will slow down the search.

#### `"Periodic"`

This option defaults to `True`, which means that it searches for periodic patterns (still lifes, oscillators, spaceships, agars). If you want to search for non-periodic patterns, you can set this option to `False`. Generally used with `"KnownCells"` or `"OtherConditions"`.

#### `"RandomArray"`

`SearchPattern` and `LifeFind` return a random result by default, which is achieved by taking XORs with a random array. If you don't need random results, you can set this option to 1, and the random array is taken as all 1; you can also set this option to 0, and the random array is taken as all 0, but the search results are generally all 0, unless `"Changing"` is set to `True`.

#### `"KnownCells"`

This option is used to specify known cells, whose value is a three-dimensional array with three dimensions corresponding to `p`, `x`, `y`. In the array, `1` represents known living cells, `0` represents known dead cells, and other values ​​represent undetermined cells. For example, `"KnownCells" -> {{{1, _}, {_, 0}}}` indicates that the first cell in the first generation of the pattern to be searched is 1, and the cell in the second row and second column is 0.

#### `"OtherConditions"`

This option is used to specify additional conditions that need to be met. In the condition, `C[i, j, t]` is used to represent the `t` generation of the cell at `(i, j)`. This condition is best written as a [conjunctive normal form](https://en.wikipedia.org/wiki/Conjunctive_normal_form) or easily converted to a conjunctive normal form. For example, if you want to find a [Phoenix](http://www.conwaylife.com/wiki/Phoenix) with a period of 2, size of no more than 16×16, you can use:

```Mathematica
LifeFind[16, 16, 2,
 "OtherConditions" ->
  Array[! C[##, 1] || ! C[##, 2] &, {16, 16}, 1, And]]
```

For example, to find a vertical [glide symmetric](https://en.wikipedia.org/wiki/Glide_reflection) spaceship with a size of no more than 17×17, a period of 4, and a speed of c/2, you can use:

```Mathematica
LifeFind[17, 17, 4, 2, 0,
 "OtherConditions" ->
  Array[C[##, 1] \[Equivalent] C[# + 1, 17 + 1 - #2, 3] &, {17, 17}, 1, And]]
```

## Other functions

In addition to `SearchPattern` and `LifeFind`, there are several functions in this package:

#### `RuleNumber`

Rewrite a rule into a large number that can be used in Mathematica's [`CellularAutomaton`](https://reference.wolfram.com/language/ref/CellularAutomaton.html) function. For example, the rule for Game of Life (`B3/S23`) is `{RuleNumber["B3/S23"], 2, {1, 1}}` in Mathematica. Only those rules mentioned earlier are supported.

#### `ToRLE`

Convert an array to the [RLE](http://www.conwaylife.com/wiki/Run_Length_Encoded) format. You can set the `"Rule"` option. Only rules for two states are supported, that is, the array can only consist of 0 and 1.

#### `FromRLE`

Convert RLE to an array. Only rules for two states are supported.

#### `FromAPGCode`

Convert [apgcode](http://www.conwaylife.com/wiki/Apgcode) into an array. Only rules for two states are supported.

#### `PlotAndPrintRLE`

Draw a pattern and print out its RLE. The pattern is inputted as a two-dimensional array. You can also input a list of two-dimensional arrays. Each element in the list represents a generation of the pattern, and `PlotAndPrintRLE` will draw each of its generations and print the first generation of RLE. You can set the `"Rule"` option. `LifeFind` is equivalent to the composition of `PlotAndPrintRLE` and `SearchPattern`.

#### `Predecessor`

Try searching for the [predecessor](http://www.conwaylife.com/wiki/Predecessor) of the pattern. `Predecessor[pattern, n]` indicates that the ancestor of the `n` generation is searched. When `n` is not specified, `n` defaults to 1, that is, it searches for the [parent](http://www.conwaylife.com/wiki/Parent). The search is limited. Even if the results cannot be found, this pattern may not be a [garden of Eden](http://www.conwaylife.com/wiki/Garden_of_Eden). You can set the `"Rule"` option.

#### `ExportGIF`

Export a pattern as a GIF file. The usage is `ExportGIF[file, pattern, gen]`, where `file`, `pattern`, `gen` are the file names, patterns (as an array), and the number of generations to be exported. You can set the `"Rule"` and `"DisplayDurations"` options, which represent the duration of each frame of the GIF, in seconds.

#### `Rules`

Given a pattern (as a three-dimensional array), gives all the rules it satisfies. The result is given in the form of an [association list](https://reference.wolfram.com/language/ref/Association.html), where `True` and `False` indicate that there must / cannot be this item in the rule. For example, `<|{"B", "0"} -> False, {"B", "3", "a"} -> True, {"S", "4", "k"} - > False|>` means that there must be `B3a` in the rule, there cannot be `B0` and `S4k`, and other items are optional. It is not supported to automatically determine whether it is a rule of `B0`; if it is a rule of `B0`, you need to manually set the option `"B0" -> True`.

#### `$Rule`

This is just a symbol, not a function, representing the global default rule (ie the default value of the `"Rule"` option). Its default value is `"B3/S23"` (Game of Life). You can change its value so that you don't have to set the `"Rule"` option when using other functions. It can also be used in a [`Block`](http://reference.wolfram.com/language/ref/Block.html) to change the local default rules.
