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
PatternRules::usage =
  "Give all possible rules of a pattern. The result is given in an \
Association, where True (resp. False) means this term should (resp. \
should not) appear in the rule.";

Begin["`Private`"];

$Rule = "B3/S23";

NbhdNumber = <|"B0" -> {0},
   "B1c" -> {1, 4, 64, 256},
   "B1e" -> {2, 8, 32, 128},
   "B2a" -> {3, 6, 9, 36, 72, 192, 288, 384},
   "B2c" -> {5, 65, 260, 320},
   "B2e" -> {10, 34, 136, 160},
   "B2i" -> {40, 130},
   "B2k" -> {12, 33, 66, 96, 129, 132, 258, 264},
   "B2n" -> {68, 257},
   "B3a" -> {11, 38, 200, 416},
   "B3c" -> {69, 261, 321, 324},
   "B3e" -> {42, 138, 162, 168},
   "B3i" -> {7, 73, 292, 448},
   "B3j" -> {14, 35, 74, 137, 164, 224, 290, 392},
   "B3k" -> {98, 140, 161, 266},
   "B3n" -> {13, 37, 67, 193, 262, 328, 352, 388},
   "B3q" -> {70, 76, 100, 196, 259, 265, 289, 385},
   "B3r" -> {41, 44, 104, 131, 134, 194, 296, 386},
   "B3y" -> {97, 133, 268, 322},
   "B4a" -> {15, 39, 75, 201, 294, 420, 456, 480},
   "B4c" -> {325},
   "B4e" -> {170},
   "B4i" -> {45, 195, 360, 390},
   "B4j" -> {106, 142, 163, 169, 172, 226, 298, 394},
   "B4k" -> {99, 141, 165, 225, 270, 330, 354, 396},
   "B4n" -> {71, 77, 263, 293, 329, 356, 449, 452},
   "B4q" -> {102, 204, 267, 417},
   "B4r" -> {43, 46, 139, 166, 202, 232, 418, 424},
   "B4t" -> {105, 135, 300, 450},
   "B4w" -> {78, 228, 291, 393},
   "B4y" -> {101, 197, 269, 323, 326, 332, 353, 389},
   "B4z" -> {108, 198, 297, 387},
   "B5a" -> {79, 295, 457, 484},
   "B5c" -> {171, 174, 234, 426},
   "B5e" -> {327, 333, 357, 453},
   "B5i" -> {47, 203, 422, 488},
   "B5j" -> {103, 205, 271, 331, 358, 421, 460, 481},
   "B5k" -> {229, 334, 355, 397},
   "B5n" -> {107, 143, 167, 233, 302, 428, 458, 482},
   "B5q" -> {110, 206, 230, 236, 299, 395, 419, 425},
   "B5r" -> {109, 199, 301, 361, 364, 391, 451, 454},
   "B5y" -> {173, 227, 362, 398},
   "B6a" -> {111, 207, 303, 423, 459, 486, 489, 492},
   "B6c" -> {175, 235, 430, 490},
   "B6e" -> {335, 359, 461, 485},
   "B6i" -> {365, 455},
   "B6k" -> {231, 237, 363, 366, 399, 429, 462, 483},
   "B6n" -> {238, 427},
   "B7c" -> {239, 431, 491, 494},
   "B7e" -> {367, 463, 487, 493},
   "B8" -> {495},
   "S0" -> {16},
   "S1c" -> {17, 20, 80, 272},
   "S1e" -> {18, 24, 48, 144},
   "S2a" -> {19, 22, 25, 52, 88, 208, 304, 400},
   "S2c" -> {21, 81, 276, 336},
   "S2e" -> {26, 50, 152, 176},
   "S2i" -> {56, 146},
   "S2k" -> {28, 49, 82, 112, 145, 148, 274, 280},
   "S2n" -> {84, 273},
   "S3a" -> {27, 54, 216, 432},
   "S3c" -> {85, 277, 337, 340},
   "S3e" -> {58, 154, 178, 184},
   "S3i" -> {23, 89, 308, 464},
   "S3j" -> {30, 51, 90, 153, 180, 240, 306, 408},
   "S3k" -> {114, 156, 177, 282},
   "S3n" -> {29, 53, 83, 209, 278, 344, 368, 404},
   "S3q" -> {86, 92, 116, 212, 275, 281, 305, 401},
   "S3r" -> {57, 60, 120, 147, 150, 210, 312, 402},
   "S3y" -> {113, 149, 284, 338},
   "S4a" -> {31, 55, 91, 217, 310, 436, 472, 496},
   "S4c" -> {341},
   "S4e" -> {186},
   "S4i" -> {61, 211, 376, 406},
   "S4j" -> {122, 158, 179, 185, 188, 242, 314, 410},
   "S4k" -> {115, 157, 181, 241, 286, 346, 370, 412},
   "S4n" -> {87, 93, 279, 309, 345, 372, 465, 468},
   "S4q" -> {118, 220, 283, 433},
   "S4r" -> {59, 62, 155, 182, 218, 248, 434, 440},
   "S4t" -> {121, 151, 316, 466},
   "S4w" -> {94, 244, 307, 409},
   "S4y" -> {117, 213, 285, 339, 342, 348, 369, 405},
   "S4z" -> {124, 214, 313, 403},
   "S5a" -> {95, 311, 473, 500},
   "S5c" -> {187, 190, 250, 442},
   "S5e" -> {343, 349, 373, 469},
   "S5i" -> {63, 219, 438, 504},
   "S5j" -> {119, 221, 287, 347, 374, 437, 476, 497},
   "S5k" -> {245, 350, 371, 413},
   "S5n" -> {123, 159, 183, 249, 318, 444, 474, 498},
   "S5q" -> {126, 222, 246, 252, 315, 411, 435, 441},
   "S5r" -> {125, 215, 317, 377, 380, 407, 467, 470},
   "S5y" -> {189, 243, 378, 414},
   "S6a" -> {127, 223, 319, 439, 475, 502, 505, 508},
   "S6c" -> {191, 251, 446, 506},
   "S6e" -> {351, 375, 477, 501},
   "S6i" -> {381, 471},
   "S6k" -> {247, 253, 379, 382, 415, 445, 478, 499},
   "S6n" -> {254, 443},
   "S7c" -> {255, 447, 507, 510},
   "S7e" -> {383, 479, 503, 509},
   "S8" -> {511}|>;

NbhdNumberT =
  KeySort@Merge[
    Table[{"B", "S"}[[#[[5]] + 1]] <> ToString@Tr@Delete[#, 5] &@
       IntegerDigits[i, 2, 9] -> i, {i, 0, 511}], # &];

NbhdNumberV =
  KeySort@Merge[
    Table[{"B", "S"}[[#[[5]] + 1]] <> ToString@Tr@#[[{2, 4, 6, 8}]] &@
       IntegerDigits[i, 2, 9] -> i, {i, 0, 511}], # &];

NbhdNumberH = <|"B0" -> {0, 4, 64, 68},
   "B1" -> {1, 2, 5, 6, 8, 12, 32, 36, 65, 66, 69, 70, 72, 76, 96,
     100, 128, 132, 192, 196, 256, 260, 320, 324},
   "B2o" -> {3, 7, 9, 13, 34, 38, 67, 71, 73, 77, 98, 102, 136, 140,
     200, 204, 288, 292, 352, 356, 384, 388, 448, 452},
   "B2m" -> {10, 14, 33, 37, 74, 78, 97, 101, 129, 133, 160, 164, 193,
      197, 224, 228, 258, 262, 264, 268, 322, 326, 328, 332},
   "B2p" -> {40, 44, 104, 108, 130, 134, 194, 198, 257, 261, 321, 325},
   "B3o" -> {11, 15, 35, 39, 75, 79, 99, 103, 137, 141, 201, 205, 290,
      294, 354, 358, 392, 396, 416, 420, 456, 460, 480, 484},
   "B3m" -> {41, 42, 45, 46, 105, 106, 109, 110, 131, 135, 138, 142,
     162, 166, 168, 172, 195, 199, 202, 206, 226, 230, 232, 236, 259,
     263, 265, 269, 289, 293, 296, 300, 323, 327, 329, 333, 353, 357,
     360, 364, 385, 386, 389, 390, 449, 450, 453, 454},
   "B3p" -> {161, 165, 225, 229, 266, 270, 330, 334},
   "B4o" -> {43, 47, 107, 111, 139, 143, 203, 207, 291, 295, 355, 359,
      393, 397, 418, 422, 424, 428, 457, 461, 482, 486, 488, 492},
   "B4m" -> {163, 167, 169, 173, 227, 231, 233, 237, 267, 271, 298,
     302, 331, 335, 362, 366, 394, 398, 417, 421, 458, 462, 481,
     485},
   "B4p" -> {170, 174, 234, 238, 297, 301, 361, 365, 387, 391, 451,
     455},
   "B5" -> {171, 175, 235, 239, 299, 303, 363, 367, 395, 399, 419,
     423, 425, 426, 429, 430, 459, 463, 483, 487, 489, 490, 493,
     494},
   "B6" -> {427, 431, 491, 495},
   "S0" -> {16, 20, 80, 84},
   "S1" -> {17, 18, 21, 22, 24, 28, 48, 52, 81, 82, 85, 86, 88, 92,
     112, 116, 144, 148, 208, 212, 272, 276, 336, 340},
   "S2o" -> {19, 23, 25, 29, 50, 54, 83, 87, 89, 93, 114, 118, 152,
     156, 216, 220, 304, 308, 368, 372, 400, 404, 464, 468},
   "S2m" -> {26, 30, 49, 53, 90, 94, 113, 117, 145, 149, 176, 180,
     209, 213, 240, 244, 274, 278, 280, 284, 338, 342, 344, 348},
   "S2p" -> {56, 60, 120, 124, 146, 150, 210, 214, 273, 277, 337, 341},
   "S3o" -> {27, 31, 51, 55, 91, 95, 115, 119, 153, 157, 217, 221,
     306, 310, 370, 374, 408, 412, 432, 436, 472, 476, 496, 500},
   "S3m" -> {57, 58, 61, 62, 121, 122, 125, 126, 147, 151, 154, 158,
     178, 182, 184, 188, 211, 215, 218, 222, 242, 246, 248, 252, 275,
     279, 281, 285, 305, 309, 312, 316, 339, 343, 345, 349, 369, 373,
     376, 380, 401, 402, 405, 406, 465, 466, 469, 470},
   "S3p" -> {177, 181, 241, 245, 282, 286, 346, 350},
   "S4o" -> {59, 63, 123, 127, 155, 159, 219, 223, 307, 311, 371, 375,
      409, 413, 434, 438, 440, 444, 473, 477, 498, 502, 504, 508},
   "S4m" -> {179, 183, 185, 189, 243, 247, 249, 253, 283, 287, 314,
     318, 347, 351, 378, 382, 410, 414, 433, 437, 474, 478, 497,
     501},
   "S4p" -> {186, 190, 250, 254, 313, 317, 377, 381, 403, 407, 467,
     471},
   "S5" -> {187, 191, 251, 255, 315, 319, 379, 383, 411, 415, 435,
     439, 441, 442, 445, 446, 475, 479, 499, 503, 505, 506, 509,
     510},
   "S6" -> {443, 447, 507, 511}|>;

NbhdNumberHT =
  KeySort@Merge[
    Table[{"B", "S"}[[#[[5]] + 1]] <>
         ToString@Tr@#[[{1, 2, 4, 6, 8, 9}]] &@
       IntegerDigits[i, 2, 9] -> i, {i, 0, 511}], # &];

RuleNumber::nrule = "Invalid rule. Uses " <> $Rule <> " instead.";
RuleNumber[n_Integer] := n;
RuleNumber[rule_String] :=
  Block[{parseNbhd, parseNbhdH, patNbhd, patNbhdH, toNum, sb},
   {parseNbhd, parseNbhdH} =
    KeyValueMap[
      n : #1 ~~ h : ("-" | "") ~~ s : (Alternatives @@ #2) ... :>
        Sequence @@ Table[n <> c,
          {c, Which[#2 == {}, {""},
            s == "" || h == "-", Complement[#2, Characters@s],
            True, Characters@s]}] &] /@
     {<|"0" | "8" -> {},
       "1" | "7" -> {"c", "e"},
       "2" | "6" -> {"a", "c", "e", "i", "k", "n"},
       "3" | "5" -> {"a", "c", "e", "i", "j", "k", "n", "q", "r", "y"},
       "4" -> {"a", "c", "e", "i", "j", "k", "n", "q", "r", "t", "w",
         "y", "z"}|>,
      <|"0" | "1" | "5" | "6" -> {},
       "2" | "3" | "4" -> {"o", "m", "p"}|>};
   {patNbhd, patNbhdH} =
    Alternatives @@
        Keys[# /.
          Verbatim[Pattern][_, p_] :> p] ... & /@
     {parseNbhd, parseNbhdH};
   toNum[{s_, b_}] :=
    BitOr @@
     Lookup[Tr /@ (2^NbhdNumber),
      Join["B" <> # & /@
        StringCases[b, parseNbhd, IgnoreCase -> True],
       "S" <> # & /@ StringCases[s, parseNbhd, IgnoreCase -> True]]];
   toNum[{s_, b_, "v"}] :=
    BitOr @@
     Lookup[Tr /@ (2^NbhdNumberV),
      Join["B" <> # & /@ Characters@b, "S" <> # & /@ Characters@s]];
   toNum[{s_, b_, "h"}] :=
    BitOr @@
     Lookup[Tr /@ (2^NbhdNumberH),
      Join["B" <> # & /@
        StringCases[b, parseNbhdH, IgnoreCase -> True],
       "S" <> # & /@
        StringCases[s, parseNbhdH, IgnoreCase -> True]]];
   sb = StringCases[
      rule, {StartOfString ~~ ("g" ~~ DigitCharacter ..) | "" ~~ "b" ~~
         b : patNbhd ~~ "/" | "/s" | "s" ~~
        s : patNbhd ~~ ("/" ~~ DigitCharacter ..) | "" ~~
        ":" | EndOfString :> {s, b},
      StartOfString ~~ s : patNbhd ~~ "/" ~~
        b : patNbhd ~~ ("/" ~~ DigitCharacter ..) | "" ~~
        ":" | EndOfString :> {s, b},
      StartOfString ~~ ("g" ~~ DigitCharacter ..) | "" ~~ "b" ~~
        b : ("0" | "1" | "2" | "3" | "4") ... ~~ "/" | "/s" | "s" ~~
        s : ("0" | "1" | "2" | "3" | "4") ... ~~ ("/" ~~
           DigitCharacter ..) | "" ~~ "v" ~~ ":" | EndOfString :>
        {s, b, "v"},
      StartOfString ~~ s : ("0" | "1" | "2" | "3" | "4") ... ~~ "/" ~~
        b : ("0" | "1" | "2" | "3" | "4") ... ~~ ("/" ~~
           DigitCharacter ..) | "" ~~ "v" ~~ ":" | EndOfString :>
        {s, b, "v"},
      StartOfString ~~ ("g" ~~ DigitCharacter ..) | "" ~~ "b" ~~
        b : patNbhdH ~~ "/" | "/s" | "s" ~~
        s : patNbhdH ~~ ("/" ~~ DigitCharacter ..) | "" ~~ "h" ~~
        ":" | EndOfString :> {s, b, "h"},
      StartOfString ~~ s : patNbhdH ~~ "/" ~~
        b : patNbhdH ~~ ("/" ~~ DigitCharacter ..) | "" ~~ "h" ~~
        ":" | EndOfString :> {s, b, "h"}},
     IgnoreCase -> True];
   If[sb == {}, Message[RuleNumber::nrule];
    RuleNumber[$Rule], toNum[sb[[1]]]]];

GenerationsNumber[rule_] :=
  If[# == {}, 2, #[[1]]] &@
   StringCases[
    rule, {StartOfString ~~ "g" ~~ g : DigitCharacter .. ~~
       "/" | "b" :> FromDigits[g],
     ___ ~~ "/" | "s" ~~ ___ ~~ "/" ~~ g : DigitCharacter .. ~~
       "" | "v" | "h" ~~ ":" | EndOfString :> FromDigits[g]},
    IgnoreCase -> True];

Options[ToRLE] = {"Rule" :> $Rule};
ToRLE[array_List, OptionsPattern[]] :=
  "x = " <> #2 <> ", y = " <> #1 <> ", rule = " <>
      OptionValue["Rule"] <> "\n" & @@ ToString /@ Dimensions@array <>
    StringRiffle[
    StringCases[
     StringReplace[
      StringReplace[
       StringReplace[
        Riffle[If[Max@array < 2, array /. {1 -> "o", 0 -> "b"},
           array /. {0 -> ".",
             n_ /; n < 25 :> FromCharacterCode[n + 64],
             n_ /; n > 24 :>
              FromCharacterCode[Quotient[n, 24, 1] + 111] <>
               FromCharacterCode[Mod[n, 24, 1] + 64]}], "$"] <> "!",
        "." | "b" .. ~~ s : "$" | "!" :> s], "$" .. ~~ "!" :> "!"],
      r : (x :
           "$" | "." | "b" | "o" |
            "*" | ("" | Alternatives @@ CharacterRange["p", "y"] ~~
              Alternatives @@ CharacterRange["A", "X"])) .. :>
       (If[# == 1, "", ToString@#] &[StringLength@r/StringLength@x]) <>
         x], l : (___ ~~
         "$" | "!" | "." | "b" | "o" | "*" |
          Alternatives @@ CharacterRange["A", "X"]) /;
      StringLength@l <= 70], "\n"];

FromRLE[rle_String] :=
  PadRight[StringCases[{"." | "b" -> 0, "o" | "*" -> 1,
      a : Alternatives @@ CharacterRange["p", "y"] ~~
        b : Alternatives @@ CharacterRange["A", "X"] :>
       Tr[24 (ToCharacterCode@a - 111) + ToCharacterCode@b - 64],
      b : Alternatives @@ CharacterRange["A", "X"] :>
       Tr[ToCharacterCode@b - 64]}] /@
    StringSplit[
     StringReplace[
      StringDelete[
       rle, (StartOfLine ~~ ("x" | "#") ~~ Shortest@___ ~~
          EndOfLine) | "\n" | ("!" ~~ ___)],
      n : DigitCharacter .. ~~
        a : ("$" | "." | "b" | "o" |
           "*" | ("" | Alternatives @@ CharacterRange["p", "y"] ~~
             Alternatives @@ CharacterRange["A", "X"])) :>
       StringRepeat[a, FromDigits@n]], "$", All]];

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
  Block[{gen = GenerationsNumber[OptionValue["Rule"]]},
   ArrayPlot[# /. i_ /; i > 0 :> (gen - i)/(gen - 1),
      FilterRules[{opts}, Options[ArrayPlot]], Mesh -> All,
      ColorFunctionScaling -> False] & /@
    Echo[If[ArrayDepth@pattern == 2, {pattern}, pattern], "RLE: ",
     ToRLE[#[[1]], "Rule" -> OptionValue["Rule"]] &]];

SearchPattern::nsat = "No such pattern.";
SearchPattern::nsym = "Invalid symmetry. Uses \"C1\" instead.";
SearchPattern::genper =
  "Nonperiodic patterns are not supported for Generations rules.";
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
  Block[{bf, gen, random, c, vcell, vchange, agarx, agary, rule,
    change, known, sym, other, result},
   bf = FromDigits[
     IntegerDigits[RuleNumber[OptionValue["Rule"]], 2, 512] + 1, 4];
   gen = GenerationsNumber[OptionValue["Rule"]];
   If[! OptionValue["Periodic"] && gen > 2,
    Message[SearchPattern::genper]];
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
    Array[BooleanConvert[((c[#, #2, #3 - 1] || !
             Array[c, {1, 1, gen - 1}, {##} - {0, 0, gen - 1}, Or]) &&
           BooleanFunction[bf,
           Flatten@{Array[c, {3, 3, 1}, {##} - 1],
             c[##]}]) ||
        (! c[#, #2, #3 - 1] &&
          Array[c, {1, 1, gen - 1}, {##} - {0, 0, gen - 1}, Or] && !
           c[##]), "CNF"] &,
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
    Nest[BlockMap[Flatten@# /.
         {{0 | gen - 1, 0} -> 0,
          {i_, 0} /; i < gen - 1 :> i + 1,
          {_, i_} /; i > 0 :> i} &,
       Prepend[#, Drop[PadRight[Last@#, {x, y} + {dx, dy}], dx, dy]],
       {2, 1, 1}, 1] &,
     Transpose[
      Mod[random + ArrayReshape[Boole@result[[1]], {x, y, p}], 2],
      {2, 3, 1}], gen - 1]]];

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

PatternRules::nrule = "No such rule.";
Options[PatternRules] := {"B0" -> False, "Hexagonal" -> False,
   "Totalistic" -> False};
PatternRules[pattern_, OptionsPattern[]] :=
  Block[{nbhd =
     If[OptionValue["Hexagonal"],
      If[OptionValue["Totalistic"], NbhdNumberHT, NbhdNumberH],
      If[OptionValue["Totalistic"], NbhdNumberT, NbhdNumber]]},
   Catch[KeySort@
     Merge[Flatten@
       BlockMap[
        Position[nbhd, FromDigits[Flatten@#[[1]], 2]][[1, 1, 1]] ->
          #[[2, 2, 2]] &,
        MapIndexed[
         ArrayPad[#, 2,
           If[OptionValue["B0"], 1/2 + (-1)^Tr@#2/2, 0]] &,
         pattern], {2, 3, 3}, 1],
      Switch[Union@#, {0}, False, {1}, True, _,
        Throw[Message[PatternRules::nrule]]] &]]];

End[];

EndPackage[];
