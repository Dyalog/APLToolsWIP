﻿ r←IWAAuthVBtxt con;tok;rr;kp;header;size;tokout
 SetProp con'IWA'('NTLM' '')
 :Repeat
     header←''
     size←0
     tok←''
     :Repeat
         rr←Wait con 1000
         :If 0=⊃rr
             :If size>0
                 tok,←4⊃rr
             :Else
                 :If 16>⍴header
                     header,←(16-⍴header)↑4⊃rr
                 :EndIf
                 :If 16=⍴header         ⍝ header form '<IWA     nnnnn>'
                 :AndIf '<'=1↑header
                 :AndIf '>'=¯1↑header
                     size←2⊃⎕VFI 5↓15↑header
                     tok←16↓4⊃rr

                 :EndIf
             :EndIf
         :EndIf
     :Until (size>0)∧size=⍴tok
     :If 0=⊃rr
         SetProp con'Token'(toAnsi tok)
         kp tokout←2⊃GetProp con'Token'
         :If kp=1
             Send con('<IWA',(¯11↑(⍕⍴tokout)),'>')
             Send con(toAv tokout)
         :Else
             r←GetProp con'IWA'
             Send con('<IWAc',(¯10↑(⍕⍴2⊃r)),'>')
             Send con(2⊃r)
         :EndIf
     :Else
         kp←1
     :EndIf
 :Until 0=kp
