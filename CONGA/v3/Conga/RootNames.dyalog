﻿ r←RootNames;i
⍝ List root names of all instances of LIB

 :If 0=⍴i←⎕INSTANCES LIB ⋄ r←0⍴⊂''
 :Else ⋄ r←i.RootName
 :EndIf
