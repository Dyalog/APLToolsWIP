    :Class Server 
        :field public DRC
        :field public address
        :field public service 
        :field public timeout
        :field Private conclass 
        :field Private events
        :field public extra
        :field private name
        :field private htid
        :field private done
        :field private HError 

          Assert←{
              ⍺=⊃⍵:⍵
              'Server error'⎕SIGNAL 999
          }

        ∇ ref←GetDRCShared
          :Access public shared
          ref←## ⍝.DRCShared
        ∇

        ∇ makeN arg
          :Access public
          :Implements constructor
          enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
          defaults←{⍺,(⍴,⍺)↓⍵}
          done←¯1
          timeout←5000
          HError←0
          events←⍬
          (DRC service conclass address extra)←(enc arg)defaults ⍬ 5000 GetDRCShared.Connection''(⎕NS'')
          :If DRC≡⍬
              DRC←GetDRCShared.Init''
          :EndIf
        ∇
    
        ∇ unmake;cons
          :Implements Destructor
          Stop
        ∇

   
        ∇ Start;err;sp;p
          :Access public
          (err name)←0 Assert DRC.Srv''address service,conclass.ServerArgs
          done←0
          sp←⎕THIS conclass.ServerProperties name
          :If 0<⍴sp
              :For p :In sp
                  _←DRC.SetProp(⊂name),p
              :EndFor
          :EndIf
         
          htid←Handler&name
        ∇
    
        ∇ Stop
          :Access public
          :if done=¯1 ⋄ :return ⋄:endif

          done←1
          cons←DRC.Names name
          :If 0≠⎕NC name
         
     ⍝⎕ex ¨(⊂name,'.'),¨cons
              (⍎name).(⎕EX¨⎕NL 9)  ⍝ Clear all the Connection instances
              ⎕EX name             ⍝ Clear the namespace for all the instances
              _←DRC.Close name     ⍝ Close the server
              ⎕DL timeout÷1000     ⍝ wait for Wait to return
          :EndIf
          :if 0≠⎕nc'htid'
          :andIf htid≠0           ⍝ if thread have not ended by it self kill it
              ⎕TKILL htid
          :EndIf
        ∇

        ∇ onTimeout
          :Access public
          :Access Overridable
         
        ∇
        

        ∇ Handler name;r;newcon;err;obj;evt;data
          ⍎name,'←⎕ns '''' '
          :While !done
              :If 0=⊃r←DRC.Wait name timeout
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
                          _←DRC.Close name
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
          :Access public
          _←⎕EX obj
          _←DRC.Close obj
        ∇

    :EndClass
