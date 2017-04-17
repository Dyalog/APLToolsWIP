 r←teardown dummy;tree;z
⍝ Teardown "iConga"

 r←verify_empty iConga

 :If 9=⎕NC'#.Conga' ⍝ Check we don't have lingering instances
     :If 0≠⍴⎕INSTANCES #.Conga.Server
         ∘∘∘
     :EndIf

     :If 0≠⍴⎕INSTANCES #.Conga.Client
         ∘∘∘
     :EndIf
 :EndIf
