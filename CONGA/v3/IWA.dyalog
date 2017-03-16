:NameSpace IWA

    ∇ r←InitRawIWA dllname
      ⍙naedfns,←⊂'IWAStart'⎕NA dllname,'IFAuthClientStart >P <0T1 <0T1'
      ⍙naedfns,←⊂'IWAGet'⎕NA dllname,'IFAuthGetToken P >U4 =U4 >C1[]'
      ⍙naedfns,←⊂'IWASet'⎕NA dllname,'IFAuthSetToken P U4  <C1[]'
      ⍙naedfns,←⊂'IWAFree'⎕NA dllname,'IFAuthFree P '
      ⍙naedfns,←⊂'IWAName'⎕NA dllname,'IFAuthName P >0T1'
      r←0
    ∇
    ∇ r←ServerAuth con;tok;rr;kp;err;rc;ct;ck;ce
      err←SetProp con'IWA'('NTLM' '')
      :Repeat
          rr←Wait con 1000
          :If 0=⊃rr
              (ce ck ct)←3↑4⊃rr
              :If 0<⍴ct
              :AndIf ce=0
                  err←SetProp con'Token'(ct)
                  kp tok←2⊃GetProp con'Token'
                  rc←Respond(2⊃rr)(err kp tok)
              :Else
                  rc←Respond(2⊃rr)(0 0 ⍬)
                  kp←0
              :EndIf
          :Else
              kp←1
          :EndIf
      :Until (0=kp)∨(ck=0)
      r←GetProp con'IWA'
    ∇

    ∇ r←ClientAuth arg;con;tok;cmd;rc;rr;kp;err;se;sk;st
      :If 1=≡arg
          arg←,⊂arg
      :EndIf
      con←1⊃arg
      err←SetProp con'IWA'('NTLM' '',1↓arg)
      :Repeat
          kp tok←2⊃GetProp con'Token'
          rc cmd←Send con(err kp tok)
          rr←Wait cmd 10000
          :If 0=⊃rr
              (se sk st)←3↑4⊃rr
     
              :If 0<⍴st
              :AndIf se=0
                  err←SetProp con'Token'(st)
              :Else
                  kp←0
              :EndIf
          :EndIf
      :Until (0=kp)∨(sk=0)
      r←GetProp con'IWA'
    ∇

    ∇ r←IWAAuth con;tok;cmd;rc;rr;kp
      err HANDLE←IWAStart 1 'NTLM' ''
      :Repeat
          err kp len tok←IWAGet HANDLE 1 200 200
          tok←len↑tok
          rc cmd←Send con tok
          rr←Wait cmd 10000
          tok←4⊃rr
          IWASet HANDLE(⍴tok)tok
      :Until 0=kp
      r←IWAName HANDLE 100
     ⍝ r←GetProp con'IWA'
    ∇
    ∇ r←toAv a;⎕IO
      ⎕IO←0
      r←⎕AV[((⎕NXLATE 0)⍳⍳256)[⎕AV⍳a]]
    ∇
    ∇ r←toAnsi a;⎕IO
      ⎕IO←0
      r←⎕AV[(⎕NXLATE 0)[⎕AV⍳a]]
    ∇

    ∇ r←IWAAuthVBtxt con;tok;rr;kp;header;size;tokout
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
     
    ∇        

:EndNamespace

