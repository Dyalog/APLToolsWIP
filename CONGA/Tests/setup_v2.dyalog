 r←setup_v2 dummy;ret
⍝ Setup test using v2 DRC
 :If 0≠⊃ret←#.DRC.Init''
     r←'#.DRC.Init failed: ',⍕ret ⋄ →0 ⋄ :EndIf
 r←verify_empty iConga←#.DRC
