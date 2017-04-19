 r←setup_v3 dummy
⍝ Setup test using v3 DRC
 Conga←#.Conga

 :Trap 0
     iConga←Conga.Init''
 :Else
     →0⊣r←'Conga.Init failed: ',⊃⎕DMX.DM
 :EndTrap

 r←verify_empty iConga
