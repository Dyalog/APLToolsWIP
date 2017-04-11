 ref←{libpath}Init arg;rootname;inst;ix;r
 :If 0=⎕NC'libpath' ⋄ libpath←'' ⋄ :EndIf
 rootname←⊃(enc arg)defaults,⊂'DRC'
 :If 0=⊃r←LoadSharedLib libpath ⍝ Sets LibPath as side-effect
     :If ⍬≡ref←FindInst rootname
         ref←##.⎕NEW DRC(LibPath rootname) ⍝ NB always create instances in the parent space
     :EndIf
 :Else
     ('Unable to load shared library: ',⍕r)⎕SIGNAL 999
 :EndIf
