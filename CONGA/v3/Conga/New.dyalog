 r←New name;names
⍝ Create a NEW instance of Conga.DRC. If name is empty, generate an unused name.

 :If (⊂name)∊names←(⎕INSTANCES DRC).RootName
     ('Name in use: ',name)⎕SIGNAL 11
 :ElseIf name∧.=' '
     name←⊃('IC'∘,¨⍕¨⍳1+≢names)~names
 :EndIf

 r←Init name
