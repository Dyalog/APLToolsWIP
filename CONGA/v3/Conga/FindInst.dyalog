﻿ ref←FindInst rootname;inst;ix
 inst←⎕INSTANCES⊃⊃⎕CLASS LIB
 :If 0<⍴inst
 :AndIf (ix←inst.RootName⍳⊂rootname)≤⍴inst
     ref←inst[ix]
 :Else
     ref←⍬
 :EndIf
