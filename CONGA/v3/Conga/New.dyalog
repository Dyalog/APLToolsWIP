﻿ r←New name;names
⍝ Create a NEW instance of Conga.LIB. If name is empty, generate an unused name.

 :If (⊂name)∊names←RootNames
     ('Name in use: ',name)⎕SIGNAL 11
 :ElseIf name∧.=' '
     name←⊃('IC'∘,¨⍕¨⍳1+≢names)~names
 :EndIf

 r←Init name
