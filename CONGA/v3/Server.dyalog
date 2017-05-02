﻿    :Class Server 
        :Field Public LIB
        :Field Public address
        :Field Public service 
        :Field Public timeout
        :Field Public extra
        :Field Private name

        :Field Private htid
        :Field Private done
        :Field Private HError 
        :Field Private conclass 
        :Field Private events

          Assert←{
              ⍺=⊃⍵:⍵
              ('Server error: ',⍕⍵)⎕SIGNAL 999
          }

        ∇ ref←Conga
          :Access Public Shared
          ref←## ⍝ Conga is the parent (as things stand)
        ∇

        ∇ makeN arg
          :Access Public
          :Implements Constructor
          enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
          defaults←{⍺,(⍴,⍺)↓⍵}
          done←¯1
          timeout←5000
          HError←0
          events←⍬
          'Please use Conga.Srv to instantiate Servers' ⎕SIGNAL (Conga≡#)/11
          (LIB service conclass address extra)←(enc arg)defaults ⍬ 5000 Conga.Connection''(⎕NS'')
          :If LIB≡⍬
              LIB←Conga.Init''
          :EndIf
        ∇
    
        ∇ unmake;cons
          :Implements Destructor
          Stop
        ∇

   
        ∇ Start;err;sp;p
          :Access Public
          (err name)←0 Assert LIB.Srv''address service,conclass.ServerArgs
          done←0
          sp←⎕THIS conclass.ServerProperties name
          :If 0<⍴sp
              :For p :In sp
                  _←LIB.SetProp(⊂name),p
              :EndFor
          :EndIf
         
          htid←Handler&name
        ∇
    
        ∇ Stop
          :Access Public
          :If done=¯1 ⋄ :Return ⋄:EndIf

          done←1
          cons←LIB.Names name
          :If 0≠⎕NC name         
              (⍎name).(⎕EX¨⎕NL 9)  ⍝ Clear all the Connection instances
              ⎕EX name             ⍝ Clear the namespace for all the instances
              _←LIB.Close name     ⍝ Close the server
              ⎕DL timeout÷1000     ⍝ wait for Wait to return
          :EndIf
          
          :If 0≠⎕nc'htid'
          :AndIf htid≠0           ⍝ if thread have not ended by it self kill it
              ⎕TKILL htid
          :EndIf
        ∇

        ∇ onTimeout
          :Access Public Overridable
        ∇
        

        ∇ Handler name;r;newcon;err;obj;evt;data
          ⍎name,'←⎕ns '''' '
          :While ~done
              :If 0=⊃r←LIB.Wait name timeout
                  (err obj evt data)←4↑r
                  :Select evt
                  :Case 'Connect'
                      newcon←⎕NEW conclass(obj ⎕THIS extra)
                      :If events≡⍬
                          events←2↓¨'on'{((⊂⍺)≡¨(⍴,⍺)↑¨⍵)/⍵}newcon.⎕NL ¯3
                      :EndIf
                      ⍎obj,'← newcon'
                      ⎕EX'newcon'
                  :CaseList 'Error' 'Close'
                      (⍎obj).onError obj data
                      Remove obj
                  :Case 'Receive'
                      ⍎('.'{(-(⌽⍵)⍳⍺)↓⍵}obj),'.on',evt,'& obj data'
                  :Case 'Timeout'
                      onTimeout
                  :Else
                      :If ∨/events∊⊂evt
                          ⍎obj,'.on',evt,'& obj data'
                      :Else
                          _←LIB.Close name
                          'unexpected event'⎕SIGNAL 999
                      :EndIf
                  :EndSelect
              :Else
                  HError←⊃r
                  done←1
              :EndIf
          :EndWhile
          htid←0
        ∇
        
        ∇ Remove obj
          :Access Public
          _←⎕EX obj
          _←LIB.Close obj
        ∇

    :EndClass
