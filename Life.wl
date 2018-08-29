(* ::Package:: *)

BeginPackage["Life`"];

$Rule::usage = "The default rule.";
RuleNumber::usage = "Convert a rule string to a rule number.";
ToRLE::usage = "Convert a 2d 0-1 array to a string of RLE format.";
FromRLE::usage = "Convert a string of RLE format to an array.";
FromAPGCode::usage = "Convert an apgcode to an array.";
PlotAndPrintRLE::usage =
  "Plot the pattern, and print the RLE of the first phase.";
SearchPattern::usage =
  "SearchPattern[x, y, p, dx, dy] searches for a pattern with \
bounding box (x, y), period p, and translating (dx, dy) for each \
period. It returns a 0-1 array.";
LifeFind::usage =
  "LifeFind[x, y, p, dx, dy] searches for a pattern with bounding box \
(x, y), period p, and translating (dx, dy) for each period. It \
returns a list of plots, and prints the RLE of the first phase.";
Parent::usage =
  "Parent[pattern] tries to find a parent of the pattern.\n\
Parent[pattern, m] pads the pattern with m 0s on each side before \
searching for the parent.";
ExportGIF::usage =
  "ExportGIF[file, pattern, n] plots the pattern for n generations \
and export it to a GIF file.";

Begin["`Private`"];

$Rule = "B3/S23";

RuleNumber::nrule = "`1` is not a valid rule. This package only \
supports totalistic and isotropic non-totalistic Life-like cellular \
automata for the Moore neighbourhood.";
RuleNumber[n_Integer] := n;
RuleNumber[rule_String] :=
  If[# == {}, Message[RuleNumber::nrule, rule]; -1, #[[1]]] &[
   StringCases[rule,
    StartOfString ~~ "b" ~~
      b : (DigitCharacter ~~ ("-" | "") ~~
          ("c" | "e" | "k" | "a" | "i" | "n" |
             "y" | "q" | "j" | "r" | "t" | "w" | "z") ...) ... ~~
      "/" | "/s" | "s" ~~
      s : (DigitCharacter ~~ ("-" | "") ~~
          ("c" | "e" | "k" | "a" | "i" | "n" |
             "y" | "q" | "j" | "r" | "t" | "w" | "z") ...) ... ~~
      EndOfString :>
     (Total[2^DeleteDuplicates@Flatten@{#, #2 + 16}] & @@
       (StringCases[#,
           KeyValueMap[
            n : # ~~ h : ("-" | "") ~~
               c : (Alternatives @@ Keys@#2) ... :>
              #2 /@ Which[c == "", Keys@#2,
                h == "-", Complement[Keys@#2, Characters@c],
                True, Characters@c] &,
            <|"0" -> <|"c" -> {0}|>,
             "1" -> <|"c" -> {256, 4, 64, 1},
               "e" -> {128, 2, 32, 8}|>,
             "2" -> <|"c" -> {320, 5, 260, 65},
               "e" -> {160, 34, 136, 10},
               "k" -> {264, 12, 96, 258, 33, 132, 66, 129},
               "a" -> {384, 6, 192, 288, 3, 36, 72, 9},
               "i" -> {130, 40},
               "n" -> {257, 68}|>,
             "3" -> <|"c" -> {324, 261, 321, 69},
               "e" -> {168, 42, 162, 138},
               "k" -> {266, 140, 98, 161},
               "a" -> {416, 38, 200, 11},
               "i" -> {448, 7, 292, 73},
               "n" -> {328, 13, 352, 262, 37, 388, 67, 193},
               "y" -> {322, 133, 268, 97},
               "q" -> {385, 70, 196, 289, 259, 100, 76, 265},
               "j" -> {392, 14, 224, 290, 35, 164, 74, 137},
               "r" -> {386, 134, 194, 296, 131, 44, 104, 41}|>,
             "4" -> <|"c" -> {325},
               "e" -> {170},
               "k" -> {354, 165, 330, 396, 141, 270, 225, 99},
               "a" -> {456, 15, 480, 294, 39, 420, 75, 201},
               "i" -> {360, 45, 390, 195},
               "n" -> {452, 263, 449, 356, 71, 293, 329, 77},
               "y" -> {332, 269, 353, 326, 101, 389, 323, 197},
               "q" -> {417, 102, 204, 267},
               "j" -> {394, 142, 226, 298, 163, 172, 106, 169},
               "r" -> {424, 46, 232, 418, 43, 166, 202, 139},
               "t" -> {450, 135, 300, 105},
               "w" -> {393, 78, 228, 291},
               "z" -> {387, 198, 297, 108}|>,
             "5" -> <|"c" -> {171, 234, 174, 426},
               "e" -> {327, 453, 333, 357},
               "k" -> {229, 355, 397, 334},
               "a" -> {79, 457, 295, 484},
               "i" -> {47, 488, 203, 422},
               "n" -> {167, 482, 143, 233, 458, 107, 428, 302},
               "y" -> {173, 362, 227, 398},
               "q" -> {110, 425, 299, 206, 236, 395, 419, 230},
               "j" -> {103, 481, 271, 205, 460, 331, 421, 358},
               "r" -> {109, 361, 301, 199, 364, 451, 391, 454}|>,
             "6" -> <|"c" -> {175, 490, 235, 430},
               "e" -> {335, 461, 359, 485},
               "k" -> {231, 483, 399, 237, 462, 363, 429, 366},
               "a" -> {111, 489, 303, 207, 492, 459, 423, 486},
               "i" -> {365, 455},
               "n" -> {238, 427}|>,
             "7" -> <|"c" -> {239, 491, 431, 494},
               "e" -> {367, 493, 463, 487}|>,
             "8" -> <|"c" -> {495}|>|>]] & /@ {b, s})),
    IgnoreCase -> True]];

Options[ToRLE] = {"Rule" :> $Rule};
ToRLE[array_List, OptionsPattern[]] :=
  "x = " <> #2 <> ", y = " <> #1 <> ", rule = " <>
      OptionValue["Rule"] <> "\n" & @@ ToString /@ Dimensions@array <>
    StringRiffle[
    StringCases[
     StringReplace[
      StringReplace[Riffle[array /. {1 -> "o", 0 -> "b"}, "$"] <> "!",
        "b" .. ~~ s : "$" | "!" :> s],
      r : (x_) .. /; StringLength@r > 1 :>
       ToString@StringLength@r <> x],
     l : (___ ~~ "o" | "b" | "$" | "!") /; StringLength@l <= 70],
    "\n"];

FromRLE[rle_String] :=
  PadRight[StringCases[{"." | "b" -> 0, "o" | "O" | "*" -> 1}] /@
    StringSplit[
     StringReplace[
      StringDelete[
       rle, (StartOfLine ~~ ("x" | "#") ~~ Shortest@___ ~~
          EndOfLine) | "\n" | ("!" ~~ ___)],
      n : DigitCharacter .. ~~ a_ :> StringRepeat[a, FromDigits@n]],
     "$"]];

FromAPGCode::napg = "Invalid apgcode.";
FromAPGCode[apgcode_String] :=
  If[# == {},
     Message[FromAPGCode::napg]; {}, #[[1]] /.
      {a___, {0 ...} ...} :> {a}] &[
   StringCases[apgcode,
    StartOfString ~~ "x" ~~ ___ ~~ "_" ~~ code : WordCharacter ... :>
     Transpose[
      Join @@ Reverse /@ IntegerDigits[#, 2, 5] & /@
       Thread@PadRight@
         StringCases[
          StringSplit[
           StringReplace[
            code, {"y" ~~ d_ :> StringRepeat["0", 4 + FromDigits@d],
             "w" -> "00", "x" -> "000"}], "z"],
          d_ :> FromDigits@d]]]];

Options[PlotAndPrintRLE] =
  Join[Options[ToRLE],
   Options[ArrayPlot] /. (Mesh -> False) -> (Mesh -> All)];
PlotAndPrintRLE[pattern_, opts : OptionsPattern[]] :=
  ArrayPlot[#, FilterRules[{opts}, Options[ArrayPlot]],
     Mesh -> All] & /@
   Echo[pattern, "RLE: ",
    ToRLE[#[[1]], "Rule" -> OptionValue["Rule"]] &];

SearchPattern::nsat = "No such pattern.";
SearchPattern::nsym =
  "Symmetry is not one of \"C1\", \"C2\", \"C4\", \"D2-\", \
\"D2\\\\\", \"D2|\", \"D2/\", \"D4+\", \"D4X\", \"D8\"; using \"C1\" \
instead.";
Options[SearchPattern] = {"Rule" :> $Rule, "Symmetry" -> "C1",
   "Agar" -> False, "Changing" -> False, "RandomArray" -> 0.5,
   "KnownCells" -> {}};
SearchPattern[x_, y_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, 1, 0, 0, opts];
SearchPattern[x_, y_, p_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, p, 0, 0, opts];
SearchPattern[x_, y_, p_, dx_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, p, dx, 0, opts];
SearchPattern[x_, y_, p_, dx_, dy_, OptionsPattern[]] :=
  Block[{rule = RuleNumber[OptionValue["Rule"]],
    r = RandomChoice[{OptionValue["RandomArray"],
        1 - OptionValue["RandomArray"]} -> {1, 0}, {x, y, p}],
    newrule, sym, b, ax, ay, c, br, bc, result},
   newrule = FromDigits[IntegerDigits[rule, 2, 512] + 1, 4];
   sym = Evaluate@BooleanConvert[Switch[OptionValue["Symmetry"],
        "C1", True,
        "C2", b[##] \[Equivalent] b[x + 1 - #, y + 1 - #2, #3],
        "C4", b[##] \[Equivalent] b[#2, x + 1 - #, #3],
        "D2-", b[##] \[Equivalent] b[x + 1 - #, #2, #3],
        "D2\\", b[##] \[Equivalent] b[#2, #, #3],
        "D2|", b[##] \[Equivalent] b[#, y + 1 - #2, #3],
        "D2/", b[##] \[Equivalent] b[y + 1 - #2, x + 1 - #, #3],
        "D4+",
        b[##] \[Equivalent] b[x + 1 - #, #2, #3] \[Equivalent]
         b[#, y + 1 - #2, #3],
        "D4X",
        b[##] \[Equivalent] b[#2, #, #3] \[Equivalent]
         b[y + 1 - #2, x + 1 - #, #3],
        "D8",
        b[##] \[Equivalent] b[#2, x + 1 - #, #3] \[Equivalent]
         b[#2, #, #3],
        _, Message[SearchPattern::nsym]; True], "CNF"] &;
   ax[{a_, _}] := ax[a];
   ax[True] = ax[0];
   ax[a_Integer] :=
    b[Mod[#1, x, 1], Mod[#2 + Quotient[#1, x, 1] a, y, 1], #3] &;
   ax[_] = If[EvenQ@rule, False, EvenQ@#3] &;
   ay[{_, a_}] := ay[a];
   ay[True] = ay[0];
   ay[a_Integer] :=
    b[Mod[#1 + Quotient[#2, y, 1] a, x, 1], Mod[#2, y, 1], #3] &;
   ay[_] = If[EvenQ@rule, False, EvenQ@#3] &;
   b[i_, j_, t_] /; t < 1 || t > p :=
    b[i - Quotient[t, p, 1] dx, j - Quotient[t, p, 1] dy,
     Mod[t, p, 1]];
   b[i_, j_, t_] /; i < 1 || i > x := ax[OptionValue["Agar"]][i, j, t];
   b[i_, j_, t_] /; j < 1 || j > y := ay[OptionValue["Agar"]][i, j, t];
   b[i_, j_, t_] :=
    If[r[[i, j, t]] == 1, ! br[i, j, t], br[i, j, t]];
   c[True] = c[{1, 2}];
   c[{t1_, t2_}] :=
    Array[BooleanConvert[
        b[##, t1] \[Xor] b[##, t2] \[Equivalent] bc[##], "CNF"] &,
      {x, y}, 1, And] && Array[bc, {x, y}, 1, Or];
   c[_] := True;
   result =
    SatisfiabilityInstances[(MapIndexed[
         Switch[#, 1, b @@ #2, 0, ! b @@ #2, _, True] &,
         Transpose[
          Switch[ArrayDepth@#, 3, #, 2, {#}, 1, {{#}}, _, {{{}}}] &@
           OptionValue["KnownCells"], {3, 1, 2}], {3}] /.
        List -> And) &&
      Array[sym[##] &&
         BooleanFunction[newrule,
          Flatten@{Array[b, {3, 3, 1}, {##} - 1], b[##]}, "CNF"] &,
       {x + 2 + Abs@dx, y + 2 + Abs@dy, p},
       {-Max[dx, 0], -Max[dy, 0], 1}, And] &&
      c[OptionValue["Changing"]],
     Flatten@{Array[br, {x, y, p}], Array[bc, {x, y}]}];
   If[result == {}, Message[SearchPattern::nsat]; {},
    Transpose[Mod[r + ArrayReshape[Boole@result[[1]], {x, y, p}], 2],
     {2, 3, 1}]]];

Options[LifeFind] =
  Union[Options[SearchPattern], Options[PlotAndPrintRLE]];
LifeFind[x_, y_, args___, opts : OptionsPattern[]] :=
  Block[{result, bounded},
   result =
    SearchPattern[x, y, args,
     FilterRules[{opts}, Options[SearchPattern]]];
   bounded[a_?AtomQ] := bounded[{a, a}];
   bounded[{0 | True, 0 | True}] :=
    ":T" <> ToString@y <> "," <> ToString@x;
   bounded[{0 | True, a_Integer}] :=
    ":T" <> ToString@y <> "," <> ToString@x <> If[a > 0, "+", ""] <>
     ToString@a;
   bounded[{a_Integer, 0 | True}] :=
    ":T" <> ToString@y <> If[a > 0, "+", ""] <> ToString@a <> "," <>
     ToString@x;
   bounded[__] = "";
   If[result != {},
    PlotAndPrintRLE[result,
     "Rule" -> OptionValue["Rule"] <> bounded[OptionValue["Agar"]]]]];

Parent::nsat = "Parent not found.";
Options[Parent] = {"Rule" :> $Rule};
Parent[pattern_, opt : OptionsPattern[]] := Parent[pattern, 0, opt];
Parent[pattern_, m_, OptionsPattern[]] :=
  Block[{rule = RuleNumber[OptionValue["Rule"]], newrule, newpattern,
    x, y, b, result},
   newrule = FromDigits[IntegerDigits[rule, 2, 512] + 1, 4];
   newpattern = ArrayPad[pattern, m + 1] /. {1 -> True, 0 -> False};
   {x, y} = Dimensions@newpattern - 2;
   b[i_, j_] /; i < 2 || j < 2 || i > x + 1 || j > y + 1 := False;
   result =
    SatisfiabilityInstances[
     Array[BooleanFunction[newrule,
        Flatten@{Array[b, {3, 3}, {##} - 1], newpattern[[##]]},
        "CNF"] &, {x, y} + 2, 1, And], Flatten@Array[b, {x, y}, 2]];
   If[result == {}, Message[Parent::nsat]; {},
    ArrayReshape[Boole@result[[1]], {x, y}]]];

Options[ExportGIF] =
  Join[{"Rule" :> $Rule, "DisplayDurations" -> 0.5},
   Options[ArrayPlot] /. (Mesh -> False) -> (Mesh -> All)];
ExportGIF[file_, pattern_, gen_, opts : OptionsPattern[]] :=
  Export[file,
   ArrayPlot[#, Mesh -> All,
      FilterRules[{opts}, Options[ArrayPlot]]] & /@
    CellularAutomaton[{RuleNumber@OptionValue["Rule"],
      2, {1, 1}}, {pattern, 0}, gen - 1],
   "DisplayDurations" -> OptionValue["DisplayDurations"],
   "AnimationRepetitions" -> Infinity];

End[];

EndPackage[];
