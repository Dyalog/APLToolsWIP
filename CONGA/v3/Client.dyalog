    :Class Client
        :Field Public LIB
        :Field Public name
        :Field Public address
        :Field Public service    
        :Field Public timeout
  
          Assert←{
              ⍺=⊃⍵:⍵
              'Server error'⎕SIGNAL 999
          }


        ∇ makeN arg;r;err
          :Access Public 
          :Implements Constructor
         
          enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
          defaults←{⍺,(⍴,⍺)↓⍵}
          name←⍬
          (LIB address service timeout)←(enc arg)defaults ⍬'localhost' 5000 20000
         
        ∇

        ∇ UnMake
          :Implements Destructor
          Close
        ∇

        ∇ err←Connect
          :Access Public
          r←0 Assert LIB.Clt''address service
          (err name)←2↑r
        ∇
                    
        ∇ Close
          :Access Public 
          :If ⍬≢name
              _←LIB.Close name
              name←⍬
          :EndIf
        ∇


        ∇ data←SendRecv req;err;cmd;obj;evt;dat
          :Access Public
          data←⍬
          ⍝ we could connect if somebody forgot
          :If ⍬≡name ⋄ Connect ⋄ :EndIf
         
          (err cmd)←0 Assert LIB.Send name req
          :While err=0
              (err obj evt dat)←4↑0 Assert LIB.Wait cmd timeout
              :If evt≢'Timeout'
                  data←dat
                  :Leave
              :EndIf
          :EndWhile
         
        ∇

    :EndClass
