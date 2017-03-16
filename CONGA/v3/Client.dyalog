    :Class Client
        :field public DRC
        :field public name
        :field public address
        :field public service    
        :field public timeout
  
          Assert←{
              ⍺=⊃⍵:⍵
              'Server error'⎕SIGNAL 999
          }


        ∇ makeN arg;r;err
          :Access public 
          :Implements Constructor
         
          enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
          defaults←{⍺,(⍴,⍺)↓⍵}
          name←⍬
          (DRC address service timeout)←(enc arg)defaults ⍬'localhost' 5000 20000
         
        ∇

        ∇ UnMake
          :Implements Destructor
          Close
        ∇

        ∇ err←Connect
          :Access public
          r←0 Assert DRC.Clt''address service
          (err name)←2↑r
        ∇
                    
        ∇ Close
          :Access public 
          :If ⍬≢name
              _←DRC.Close name
              name←⍬
          :EndIf
        ∇


        ∇ data←SendRecv req;err;cmd;obj;evt;dat
          :Access public
          data←⍬
          ⍝ we could connect if somebody forgot
          :If ⍬≡name ⋄ Connect ⋄ :EndIf
         
          (err cmd)←0 Assert DRC.Send name req
          :While err=0
              (err obj evt dat)←4↑0 Assert DRC.Wait cmd timeout
              :If evt≢'Timeout'
                  data←dat
                  :Leave
              :EndIf
          :EndWhile
         
        ∇

    :EndClass
