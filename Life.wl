(* ::Package:: *)

BeginPackage["Life`"];

$Rule::usage = "The global rule.";
RuleNumber::usage = "Convert a rule string to a rule number.";
ToRLE::usage = "Convert a 2d 0-1 array to a string of RLE format.";
FromRLE::usage = "Convert a string of RLE format to an array.";
FromAPGCode::usage = "Convert an apgcode to an array.";
SearchPattern::usage =
  "SearchPattern[x, y, p, dx, dy] searches for a pattern with \
bounding box (x, y), period p, and translating (dx, dy) for each \
period. It returns a 0-1 array.";
LifeFind::usage =
  "LifeFind[x, y, p, dx, dy] searches for a pattern with bounding box \
(x, y), period p, and translating (dx, dy) for each period. It \
returns a list of plots, and prints the RLE of the first phrase.";
ExportGIF::usage = "ExportGIF[file, pattern, gen] generates plots of \
the pattern, and exports it to a GIF file.";

Begin["`Private`"];

$Rule = "B3/S23";

RuleNumber::nrule = "`1` is not a valid rule. This package only \
supports totalistic and isotropic non-totalistic Life-like cellular \
automata for the Moore neighbourhood.";
RuleNumber["Life"] = RuleNumber["B3/S23"];
RuleNumber["GameOfLife"] = RuleNumber["B3/S23"];
RuleNumber["Game Of Life"] = RuleNumber["B3/S23"];
RuleNumber["Conway"] = RuleNumber["B3/S23"];
RuleNumber["Conway's Game of Life"] = RuleNumber["B3/S23"];
RuleNumber["34Life"] = RuleNumber["B34/S34"];
RuleNumber["3-4 Life"] = RuleNumber["B34/S34"];
RuleNumber["HighLife"] = RuleNumber["B36/S23"];
RuleNumber["AntiLife"] = RuleNumber["B0123478/S01234678"];
RuleNumber["Life without Death"] = RuleNumber["B3/S012345678"];
RuleNumber["Plow World"] = RuleNumber["B378/S012345678"];
RuleNumber["PlowWorld"] = RuleNumber["B378/S012345678"];
RuleNumber["Day and Night"] = RuleNumber["B3678/S34678"];
RuleNumber["Day & Night"] = RuleNumber["B3678/S34678"];
RuleNumber["Day&Night"] = RuleNumber["B3678/S34678"];
RuleNumber["Diamoeba"] = RuleNumber["B35678/S5678"];
RuleNumber["LongLife"] = RuleNumber["B345/S5"];
RuleNumber["Seeds"] = RuleNumber["B2/S"];
RuleNumber["Persian Rug"] = RuleNumber["B234/S"];
RuleNumber["PersianRug"] = RuleNumber["B234/S"];
RuleNumber["Replicator"] = RuleNumber["B1357/S1357"];
RuleNumber["Morley"] = RuleNumber["B368/S245"];
RuleNumber["Move"] = RuleNumber["B368/S245"];
RuleNumber["2\[Times]2"] = RuleNumber["B36/S125"];
RuleNumber["2x2"] = RuleNumber["B36/S125"];
RuleNumber["Gnarl"] = RuleNumber["B1/S1"];
RuleNumber["DotLife"] = RuleNumber["B3/S023"];
RuleNumber["DryLife"] = RuleNumber["B37/S23"];
RuleNumber["EightLife"] = RuleNumber["B3/S238"];
RuleNumber["Pulsar Life"] = RuleNumber["B3/S238"];
RuleNumber["PulsarLife"] = RuleNumber["B3/S238"];
RuleNumber["HoneyLife"] = RuleNumber["B38/S238"];
RuleNumber["Pedestrian Life"] = RuleNumber["B38/S23"];
RuleNumber["PedestrianLife"] = RuleNumber["B38/S23"];
RuleNumber["LowDeath"] = RuleNumber["B368/S238"];
RuleNumber["Flock"] = RuleNumber["B3/S12"];
RuleNumber["Gems"] = RuleNumber["B3457/S4568"];
RuleNumber["Live Free or Die"] = RuleNumber["B2/S0"];
RuleNumber["Maze"] = RuleNumber["B3/S12345"];
RuleNumber["Stains"] = RuleNumber["B3678/S235678"];
RuleNumber["GlideLife"] = RuleNumber["B34ek5ak/S2-c34z"];
RuleNumber["Goat Flock"] = RuleNumber["B2in3/S123a"];
RuleNumber["GoatFlock"] = RuleNumber["B2in3/S123a"];
RuleNumber["Goats"] = RuleNumber["B2in3/S123a"];
RuleNumber["Just Friends"] = RuleNumber["B2-a/S12"];
RuleNumber["JustFriends"] = RuleNumber["B2-a/S12"];
RuleNumber["Salad"] = RuleNumber["B2i34c/S2-i3"];
RuleNumber["Snowflakes"] = RuleNumber["B2ci3ai4c8/S02ae3eijkq4iz5ar6i7e"];
RuleNumber["tlife"] = RuleNumber["B3/S2-i34q"];
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
ToRLE[array_, OptionsPattern[]] :=
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

FromRLE[rle_] :=
  PadRight[StringCases[{"." | "b" -> 0, "o" | "O" | "*" -> 1}] /@
    StringSplit[
     StringReplace[
      StringDelete[
       rle, (StartOfLine ~~ ("x" | "#") ~~ Shortest@___ ~~
          EndOfLine) | "\n" | ("!" ~~ ___)],
      n : DigitCharacter .. ~~ a_ :> StringRepeat[a, FromDigits@n]],
     "$"]];

FromAPGCode::napg = "Invalid apgcode.";
FromAPGCode[apgcode_] :=
  If[# == {}, Message[FromAPGCode::napg]; {}, #[[1]]] &[
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

Options[SearchPattern] = {"Rule" :> $Rule, "Symmetry" -> "C1"};
SearchPattern[x_, y_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, 1, 0, 0, opts];
SearchPattern[x_, y_, p_, opts : OptionsPattern[]] :=
  SearchPattern[x, y, p, 0, 0, opts];
SearchPattern[x_, y_, p_, dx_, dy_, OptionsPattern[]] :=
  Block[{b, r = RandomInteger[1, {x, y, p}]},
   Transpose[
      Mod[r + ArrayReshape[Boole@#, {x, y, p}], 2], {2, 3, 1}] &@
    SatisfiabilityInstances[
      Array[BooleanConvert[Switch[OptionValue["Symmetry"],
              "C1", True,
              "C2", b[##] \[Equivalent] b[x + 1 - #, y + 1 - #2, #3],
              "C4", b[##] \[Equivalent] b[#2, x + 1 - #, #3],
              "D2-", b[##] \[Equivalent] b[x + 1 - #, #2, #3],
              "D2\\", b[##] \[Equivalent] b[#2, #, #3],
              "D2|", b[##] \[Equivalent] b[#, y + 1 - #2, #3],
              "D2/",
              b[##] \[Equivalent] b[y + 1 - #2, x + 1 - #, #3],
              "D4+",
              b[##] \[Equivalent] b[x + 1 - #, #2, #3] \[Equivalent]
               b[#, y + 1 - #2, #3],
              "D4X",
              b[##] \[Equivalent] b[#2, #, #3] \[Equivalent]
               b[y + 1 - #2, x + 1 - #, #3],
              "D8",
              b[##] \[Equivalent] b[x + 1 - #, #2, #3] \[Equivalent]
               b[#, y + 1 - #2, #3] \[Equivalent] b[#2, #, #3],
              _, True] &&
             (b[##] \[Equivalent]
               BooleanFunction[RuleNumber[OptionValue["Rule"]],
                Flatten@Array[b, {3, 3, 1}, {##} - 1]]) /.
            b[i_, j_, 0] :> b[i + dx, j + dy, p] /.
           b[i_, j_, t_] /; i < 1 || i > x || j < 1 || j > y :>
            False /.
          b[i_, j_, t_] /; r[[i, j, t]] == 1 :> ! b[i, j, t],
         "CNF"] &, {x + 2, y + 2, p}, {0, 0, 1}, And],
      Flatten@Array[b, {x, y, p}]][[1]]];

Options[LifeFind] =
  Join[Options[SearchPattern],
   Options[ArrayPlot] /. (Mesh -> False) -> (Mesh -> All)];
LifeFind[args__, opts : OptionsPattern[]] :=
  ArrayPlot[#, Mesh -> All,
     FilterRules[{opts}, Options[ArrayPlot]]] & /@
   Echo[SearchPattern[args,
     FilterRules[{opts}, Options[SearchPattern]]], "RLE: ",
    ToRLE[#[[1]], "Rule" -> OptionValue["Rule"]] &];

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
