 r←test_websocket dummy;Port;Host;nl;maxwait;Features;MaxSize;to83;utf8;ret;srv;clt;res;Continuation;drt;len;data;Fin;testname;offset;z;wscon
⍝ Test upgrade of http connection to websocket
 Port←8088 ⋄ Host←'localhost'
 nl←⎕UCS 13 10
 maxwait←5000 ⋄ MaxSize←450000
 Features←1   ⍝ Feature 0=APL negotiate 1=AutoUpgrade
 to83←{⍵+¯256×⍵>127}

 utf8←{
     b←127 2047 65535 2097151 67108863 2147483647
     us←1 2 3 4 5 6
     d←1 2 2 4 4 4
     ⍺=80:⎕UCS ⍵↑(,⍉0 1∘.+1↑b),?⍵⍴255
     ⍺=160:⎕UCS ⍵↑(,⍉0 1∘.+2↑b),(3⊃b),?⍵⍴65535
     ⍺=320:⎕UCS ⍵↑(,⍉0 1∘.+3↑b),1114111,?⍵⍴1114111
     ⎕SIGNAL 11
 }
 testname←''
 :If 0 check⊃ret←iConga.SetProp'.' 'EventMode' 1
     →fail because'Set EventMode to 0 failed: ',,⍕ret ⋄ :EndIf

 :If (0)check⊃ret←iConga.Srv'' ''Port'http'MaxSize
     →fail because'Srv failed: ',,⍕ret ⋄ :EndIf
 srv←2⊃ret

 ⍝ Set feature for server applies to all incomming connections
 :If 0 check⊃ret←iConga.SetProp srv'WSFeatures'Features
     →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf

 :If 0 check⊃ret←iConga.Clt''Host Port'http'MaxSize
     →fail because'Clt failed: ',,⍕ret ⋄ :EndIf
 clt←2⊃ret

 :If 0 check⊃ret←iConga.SetProp clt'WSFeatures'Features
     →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Connect' 0)check(⊂1 3 4)⌷4↑ret←iConga.Wait srv maxwait
     →fail because'Srv Wait did not produce a Connect event: ',,⍕ret ⋄ :EndIf

 ⍝ Client requests to upgrade the connection 4th arg is extra headers remember to add nl
 :If 0 check⊃ret←iConga.SetProp clt'WSUpgrade'('/' 'localhost'('BHCHeader: Gil',nl))
     →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf


 res←iConga.Wait srv maxwait
 :If 0 'WSUpgrade'≡res[1 3]
    ⍝ Auto upgrade event 4⊃c is the Incomming request but connection have been upgraded
     wscon←2⊃res
 :ElseIf 0 'WSUpgradeReq'≡res[1 3]
    ⍝ Negotiate inspect headers and accept request with the extra headers you need.
     wscon←2⊃res
     :If 0 check⊃ret←iConga.SetProp wscon'WSAccept'((4⊃res)('GILHeader: bhc',nl))
         →fail beacuse'SetProp failed: ',,⍕ret ⋄ :EndIf
 :Else
     →fail because'Bad result from Srv Wait: ',,⍕res
 :EndIf
⍝ ⎕DL 5
 res←iConga.Wait clt maxwait
 :If 0 'WSUpgrade'≡res[1 3]
    ⍝ Auto upgrade event 4⊃c is the Incomming request but connection have been upgraded
 :ElseIf 0 'WSResponce'≡res[1 3]
    ⍝ Negotiate inspect headers and accept request with the extra headers you need.
     :If 0 check⊃ret←iConga.SetProp clt'WSAccept'((4⊃res)'')
         →fail because'SetProp failed: ',,⍕ret ⋄ :EndIf
 :Else
     →fail because'Bad result from clt Wait: ',,⍕res
 :EndIf

 :For Continuation :In 0 1
  ⍝ Test text (utf8) buffers
     :For drt :In 80 160 320
         :For len :In 0 10 124 125 126 127 128 65535 65536 70000
             data←drt utf8 len ⍝
             Fin←⊃(1(len=70000))[⎕IO+Continuation]
             testname←' WebSocket Text APL Datatype ',(⍕⎕DR data),' buffer length ',(⍕len),Continuation/' and Continuation '

             :If (0)check⊃ret←iConga.Send clt(data Fin)
                 →fail because'Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 'WSReceive'(data Fin 1))check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
                 →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

             :If (0)check⊃ret←iConga.Send wscon(data Fin)
                 →fail because'Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 'WSReceive'(data Fin 1))check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
                 →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :EndFor
     :EndFor

 ⍝ Test binary  buffers
     :For offset :In -⎕IO+0 128
         :For len :In 0 10 124 125 126 127 128 65535 65536 70000
             data←offset+len⍴⍳256
             testname←' WebSocket Text APL Datatype ',(⍕⎕DR data),' and buffer length ',(⍕len),Continuation/' and Continuation '
             Fin←⊃(1(len=70000))[⎕IO+Continuation]

             :If (0)check⊃ret←iConga.Send clt(data Fin)
                 →fail because'Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 'WSReceive'((to83 data)Fin 2))check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
                 →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

             :If (0)check⊃ret←iConga.Send wscon(data Fin)
                 →fail because'Send failed: ',,⍕ret ⋄ :EndIf

             :If (0 'WSReceive'((to83 data)Fin 2))check(⊂1 3 4)⌷4↑res←iConga.Wait clt maxwait
                 →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf
         :EndFor
     :EndFor
 :EndFor
 ⍝ Shutdown
 :If 0 check⊃ret←iConga.Close clt
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 :If (0 'Closed' 1119)check(⊂1 3 4)⌷4↑res←iConga.Wait srv maxwait
     →fail because'Bad result from Srv Wait: ',,⍕res ⋄ :EndIf

 :If 0 check⊃ret←iConga.Close srv
     →fail because'Close failed: ',,⍕ret ⋄ :EndIf

 r←''   ⍝ surprise all worked!
 →0
fail:
 z←iConga.Close¨clt srv
 r←r,' for ',testname
