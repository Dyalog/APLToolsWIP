 ref←Init arg;path;rootname;inst;ix
 (path rootname)←(enc arg)defaults'' 'DRC'
 :If 0=⊃LoadSharedLib path
     :If ⍬≡ref←FindInst rootname
         ref←⎕NEW DRC(⎕THIS PATH rootname)
     :EndIf
 :Else
     'Unable to load sharedlib'⎕SIGNAL 999
 :EndIf
