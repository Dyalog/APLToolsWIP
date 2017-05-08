﻿ p←DefPath p;ds;trunkds;addds;isWin;subst
 subst←{((1⊃⍺),⍵)[1+(⍳⍴⍵)×⍵≠2⊃⍺]}
 isWin←{'Window'{⍺≡(⍴⍺)↑⍵}⎕IO⊃'.'⎕WG'aplversion'}
 ds←'/\'[⎕IO+isWin ⍬]
 trunkds←{⍺←ds ⋄ (1-(⌽⍵)⍳⍺)↓⍵}
 addds←{⍺←ds ⋄ ⍵,(⍺≠¯1↑⍵)/⍺}

 :Select p
 :Case '⍵' ⍝ means path of the ws
     p←trunkds ⎕WSID
 :Case '↓' ⍝ means current path
     :If isWin ⍬
         p←addds⊃⎕CMD'cd'
     :Else
         p←addds⊃⎕CMD'pwd'
     :EndIf
 :Case '⍺' ⍝ means the path of the interpreter
     p←trunkds ⎕IO⊃+2 ⎕NQ'.' 'GetCommandlineArgs'
 :CaseList ⍬ ''
     p←p
 :Else
     p←addds((isWin ⍬)⌽'/\')subst p
 :EndSelect
