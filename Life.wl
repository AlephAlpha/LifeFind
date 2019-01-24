(* ::Package:: *)

BeginPackage["Life`"];

$Rule::usage = "The default rule.";
RuleNumber::usage = "Convert a rule string to a rule number.";
ToRLE::usage = "Convert a 2d 0-1 array to a string of RLE format.";
FromRLE::usage = "Convert a string of RLE format to an array.";
FromAPGCode::usage = "Convert an apgcode to an array.";
PlotAndPrintRLE::usage =
  "Plot the pattern, and print the RLE of the first generation.";
SearchPattern::usage =
  "SearchPattern[x, y, p, dx, dy] searches for a pattern with \
bounding box (x, y), period p, and translating (dx, dy) for each \
period. It returns a 0-1 array.";
LifeFind::usage =
  "LifeFind[x, y, p, dx, dy] searches for a pattern with bounding box \
(x, y), period p, and translating (dx, dy) for each period. It \
returns a list of plots, and prints the RLE of the first generation.";
Predecessor::usage =
  "Predecessor[pattern, n] tries to find a predecessor of n \
generations of the pattern.";
CA::usage =
  "CA[pattern, n, \"Rule\" -> rule] gives \
CellularAutomaton[{RuleNumber[rule], 2, {1, 1}}, {pattern, 0}, gen].";
ExportGIF::usage =
  "ExportGIF[file, pattern, n] plots the pattern for n generations \
and export it to a GIF file.";
Rules::usage =
  "Give all possible rules of a pattern. The result is given in an \
Association, where True (resp. False) means this term should (resp. \
should not) appear in the rule.";

Begin["`Private`"];

$Rule = "B3/S23";

RuleB = <|"0" -> <|"c" -> {0}|>,
   "1" -> <|"c" -> {1, 4, 64, 256},
     "e" -> {2, 8, 32, 128}|>,
   "2" -> <|"a" -> {3, 6, 9, 36, 72, 192, 288, 384},
     "c" -> {5, 65, 260, 320},
     "e" -> {10, 34, 136, 160},
     "i" -> {40, 130},
     "k" -> {12, 33, 66, 96, 129, 132, 258, 264},
     "n" -> {68, 257}|>,
   "3" -> <|"a" -> {11, 38, 200, 416},
     "c" -> {69, 261, 321, 324},
     "e" -> {42, 138, 162, 168},
     "i" -> {7, 73, 292, 448},
     "j" -> {14, 35, 74, 137, 164, 224, 290, 392},
     "k" -> {98, 140, 161, 266},
     "n" -> {13, 37, 67, 193, 262, 328, 352, 388},
     "q" -> {70, 76, 100, 196, 259, 265, 289, 385},
     "r" -> {41, 44, 104, 131, 134, 194, 296, 386},
     "y" -> {97, 133, 268, 322}|>,
   "4" -> <|"a" -> {15, 39, 75, 201, 294, 420, 456, 480},
     "c" -> {325},
     "e" -> {170},
     "i" -> {45, 195, 360, 390},
     "j" -> {106, 142, 163, 169, 172, 226, 298, 394},
     "k" -> {99, 141, 165, 225, 270, 330, 354, 396},
     "n" -> {71, 77, 263, 293, 329, 356, 449, 452},
     "q" -> {102, 204, 267, 417},
     "r" -> {43, 46, 139, 166, 202, 232, 418, 424},
     "t" -> {105, 135, 300, 450},
     "w" -> {78, 228, 291, 393},
     "y" -> {101, 197, 269, 323, 326, 332, 353, 389},
     "z" -> {108, 198, 297, 387}|>,
   "5" -> <|"a" -> {79, 295, 457, 484},
     "c" -> {171, 174, 234, 426},
     "e" -> {327, 333, 357, 453},
     "i" -> {47, 203, 422, 488},
     "j" -> {103, 205, 271, 331, 358, 421, 460, 481},
     "k" -> {229, 334, 355, 397},
     "n" -> {107, 143, 167, 233, 302, 428, 458, 482},
     "q" -> {110, 206, 230, 236, 299, 395, 419, 425},
     "r" -> {109, 199, 301, 361, 364, 391, 451, 454},
     "y" -> {173, 227, 362, 398}|>,
   "6" -> <|"a" -> {111, 207, 303, 423, 459, 486, 489, 492},
     "c" -> {175, 235, 430, 490},
     "e" -> {335, 359, 461, 485},
     "i" -> {365, 455},
     "k" -> {231, 237, 363, 366, 399, 429, 462, 483},
     "n" -> {238, 427}|>,
   "7" -> <|"c" -> {239, 431, 491, 494},
     "e" -> {367, 463, 487, 493}|>,
   "8" -> <|"c" -> {495}|>|>;

RuleS = RuleB + 16;

RuleNumber::nrule =
  "`1` is not a valid rule. This package only supports totalistic and \
isotropic non-totalistic Life-like cellular automata for the Moore \
neighbourhood. Using " <> $Rule <> " instead.";
RuleNumber[n_Integer] := n;
RuleNumber[rule_String] :=
  If[# == {}, Message[RuleNumber::nrule, rule];
     RuleNumber[$Rule], #[[1]]] &[
   StringCases[rule,
    StartOfString ~~ "b" ~~
      b : (DigitCharacter ~~ ("-" |
            "") ~~ ("c" | "e" | "k" | "a" | "i" | "n" | "y" | "q" |
             "j" | "r" | "t" | "w" | "z") ...) ... ~~
      "/" | "/s" | "s" ~~
      s : (DigitCharacter ~~ ("-" |
            "") ~~ ("c" | "e" | "k" | "a" | "i" | "n" | "y" | "q" |
             "j" | "r" | "t" | "w" | "z") ...) ... ~~ EndOfString :>
     Total[2^DeleteDuplicates@
        Flatten@MapThread[
          StringCases[#,
            KeyValueMap[
             n : # ~~ h : ("-" | "") ~~
                c : (Alternatives @@ Keys@#2) ... :> #2 /@
                Which[c == "", Keys@#2, h == "-",
                 Complement[Keys@#2, Characters@c], True,
                 Characters@c] &, #2]] &, {{b, s}, {RuleB, RuleS}}]],
    IgnoreCase -> True]];

Options[ToRLE] = {"Rule" :> $Rule};
ToRLE[array_List, OptionsPattern[]] :=
  "x = " <> #2 <> ", y = " <> #1 <> ", rule = " <>
      OptionValue["Rule"] <> "\n" & @@ ToString /@ Dimensions@array <>
    StringRiffle[
    StringCases[
     StringReplace[
      StringReplace[
       StringReplace[
        Riffle[array /. {1 -> "o", 0 -> "b"}, "$"] <> "!",
        "b" .. ~~ s : "$" | "!" :> s], "$" .. ~~ "!" :> "!"],
      r : (x_) .. /; StringLength@r > 1 :>
       ToString@StringLength@r <> x],
     l : (___ ~~ "o" | "b" | "$" | "!") /; StringLength@l <= 70],
    "\n"];

FromRLE[rle_String] :=
  PadRight[StringCases[{"." | "b" -> 0, "o" | "O" | "*" -> 1,
      a_?UpperCaseQ :> Tr@ToCharacterCode@a - 64}] /@
    StringSplit[
     StringReplace[
      StringDelete[
       rle, (StartOfLine ~~ ("x" | "#") ~~ Shortest@___ ~~
          EndOfLine) | "\n" | ("!" ~~ ___)],
      n : DigitCharacter .. ~~ a_ :> StringRepeat[a, FromDigits@n]],
     "$", All]];

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
  If[ArrayDepth@pattern == 2,
   ArrayPlot[
    Echo[pattern, "RLE: ", ToRLE[#, "Rule" -> OptionValue["Rule"]] &],
     FilterRules[{opts}, Options[ArrayPlot]], Mesh -> All],
   ArrayPlot[#, FilterRules[{opts}, Options[ArrayPlot]],
      Mesh -> All] & /@
    Echo[pattern, "RLE: ",
     ToRLE[#[[1]], "Rule" -> OptionValue["Rule"]] &]];

SearchPattern::nsat = "No such pattern.";
SearchPattern::nsym =
  "Symmetry is not one of \"C1\", \"C2\", \"C4\", \"D2-\", \
\"D2\\\\\", \"D2|\", \"D2/\", \"D4+\", \"D4X\", \"D8\"; using \"C1\" \
instead.";
Options[SearchPattern] = {"Rule" :> $Rule, "Symmetry" -> "C1",
   "Periodic" -> True, "Agar" -> False, "Changing" -> False,
   "RandomArray" -> 0.5, "KnownCells" -> {},
   "OtherConditions" -> True};
SearchPattern[x_, y_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, 1, 0, 0, opts];
SearchPattern[x_, y_, p_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, p, 0, 0, opts];
SearchPattern[x_, y_, p_, dx_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, p, dx, 0, opts];
SearchPattern[x_, y_, p_, dx_, dy_, OptionsPattern[]] :=
  Block[{bf, random, c, vcell, vchange, agarx, agary, rule, change,
    known, sym, other, result},
   bf = FromDigits[
     IntegerDigits[RuleNumber[OptionValue["Rule"]], 2, 512] + 1, 4];
   agarx[{a_, _}] := agarx[a];
   agarx[True] = agarx[0];
   agarx[a_Integer] :=
    c[Mod[#1, x, 1], Mod[#2 + Quotient[#1, x, 1] a, y, 1], #3] &;
   agarx[_] = If[OddQ@bf, False, EvenQ@#3] &;
   agary[{_, a_}] := agary[a];
   agary[True] = agary[0];
   agary[a_Integer] :=
    c[Mod[#1 + Quotient[#2, y, 1] a, x, 1], Mod[#2, y, 1], #3] &;
   agary[_] = If[OddQ@bf, False, EvenQ@#3] &;
   random =
    RandomChoice[{OptionValue["RandomArray"],
       1 - OptionValue["RandomArray"]} -> {1, 0}, {x, y, p}];
   c[i_, j_, t_] /; t < 1 || t > p :=
    c[i - Quotient[t, p, 1] dx, j - Quotient[t, p, 1] dy,
     Mod[t, p, 1]];
   c[i_, j_, t_] /; i < 1 || i > x :=
    agarx[OptionValue["Agar"]][i, j, t];
   c[i_, j_, t_] /; j < 1 || j > y :=
    agary[OptionValue["Agar"]][i, j, t];
   c[i_, j_, t_] :=
    If[random[[i, j, t]] == 1, ! vcell[i, j, t], vcell[i, j, t]];
   rule =
    Array[BooleanFunction[bf,
       Flatten@{Array[c, {3, 3, 1}, {##} - 1], c[##]}, "CNF"] &,
     {x + 2 + Abs@dx, y + 2 + Abs@dy,
      If[OptionValue["Periodic"], p, p - 1]},
     {-Max[dx, 0], -Max[dy, 0], If[OptionValue["Periodic"], 1, 2]},
     And];
   change[True] = change[{1, 2}];
   change[{t1_, t2_}] :=
    Array[BooleanConvert[
        c[##, t1] \[Xor] c[##, t2] \[Equivalent] vchange[##], "CNF"] &,
      {x, y}, 1, And] && Array[vchange, {x, y}, 1, Or];
   change[_] := True;
   known =
    MapIndexed[Switch[#, 1, c @@ #2, 0, ! c @@ #2, _, True] &,
      Transpose[
       Switch[ArrayDepth@#, 3, #, 2, {#}, 1, {{#}}, _, {{{}}}] &[
        PadRight[1 + OptionValue["KnownCells"]] - 1],
       {3, 1, 2}], {3}] /. List -> And;
   sym = Array[BooleanConvert[Switch[OptionValue["Symmetry"],
        "C1", True,
        "C2", c[##] \[Equivalent] c[x + 1 - #, y + 1 - #2, #3],
        "C4", c[##] \[Equivalent] c[#2, x + 1 - #, #3],
        "D2-", c[##] \[Equivalent] c[x + 1 - #, #2, #3],
        "D2\\", c[##] \[Equivalent] c[#2, #, #3],
        "D2|", c[##] \[Equivalent] c[#, y + 1 - #2, #3],
        "D2/", c[##] \[Equivalent] c[y + 1 - #2, x + 1 - #, #3],
        "D4+",
        c[##] \[Equivalent] c[x + 1 - #, #2, #3] \[Equivalent]
         c[#, y + 1 - #2, #3],
        "D4X",
        c[##] \[Equivalent] c[#2, #, #3] \[Equivalent]
         c[y + 1 - #2, x + 1 - #, #3],
        "D8",
        c[##] \[Equivalent] c[#2, x + 1 - #, #3] \[Equivalent]
         c[#2, #, #3],
        _, Message[SearchPattern::nsym]; True], "CNF"] &,
     {x, y, p}, 1, And];
   other =
    BooleanConvert[OptionValue["OtherConditions"] /. C -> c, "CNF"];
   result =
    SatisfiabilityInstances[
     known && sym && other && rule && change[OptionValue["Changing"]],
      Flatten@{Array[vcell, {x, y, p}], Array[vchange, {x, y}]},
     Method -> "SAT"];
   If[result == {}, Message[SearchPattern::nsat]; {},
    Transpose[
     Mod[random + ArrayReshape[Boole@result[[1]], {x, y, p}], 2],
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

Options[Predecessor] =
  FilterRules[Options[SearchPattern], Except["Periodic"]];
Predecessor[pattern_, opt : OptionsPattern[]] :=
  Predecessor[pattern, 1, opt];
Predecessor[pattern_, n_, opt : OptionsPattern[]] :=
  SearchPattern[Dimensions[pattern][[1]], Dimensions[pattern][[2]],
   n + 1, "Periodic" -> False, opt,
   "KnownCells" -> Append[ConstantArray[{}, n], pattern]];

Options[CA] = {"Rule" :> $Rule};
CA[pattern_, gen_, opts : OptionsPattern[]] :=
  CellularAutomaton[{RuleNumber@OptionValue["Rule"],
    2, {1, 1}}, {pattern, 0}, gen];

Options[ExportGIF] =
  Join[{"DisplayDurations" -> 0.5}, Options[CA],
   Options[ArrayPlot] /. (Mesh -> False) -> (Mesh -> All)];
ExportGIF[file_, pattern_, gen_, opts : OptionsPattern[]] :=
  Export[file,
   ArrayPlot[#, Mesh -> All,
      FilterRules[{opts}, Options[ArrayPlot]]] & /@
    CA[pattern, gen - 1, FilterRules[{opts}, Options[CA]]],
   "DisplayDurations" -> OptionValue["DisplayDurations"],
   "AnimationRepetitions" -> Infinity];

Rules::nrule = "No such rule.";
Options[Rules] := {"B0" -> False};
Rules[pattern_, OptionsPattern[]] :=
  Check[KeyMap[# /. {h_, n : "0" | "8", "c"} :> {h, n} &]@
    KeySort@Merge[
      Flatten@BlockMap[
        Position[<|"B" -> RuleB, "S" -> RuleS|>,
            FromDigits[Flatten@#[[1]], 2]][[1, ;; 3, 1]] -> #[[2, 2,
            2]] &, MapIndexed[
         ArrayPad[#, 2,
           If[OptionValue["B0"], 1/2 + (-1)^Tr@#2/2, 0]] &,
         pattern], {2, 3, 3}, 1],
      Switch[Union@#, {0}, False, {1}, True, _,
        Message[Rules::nrule]] &], Null,
   Rules::nrule];

End[];

EndPackage[];
