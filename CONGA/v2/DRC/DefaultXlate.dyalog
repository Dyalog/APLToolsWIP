﻿ r←DefaultXlate;⎕IO;x1;x2
    ⍝ Retrieve Default translate tables for Dyalog APL

 ⎕IO←0
 x1←⎕NXLATE 0
 x2←x1⍳⍳⍴x1

 r←'DYA_IN' 'ASCII'(⎕AV[x1])(⎕AV[x2])
