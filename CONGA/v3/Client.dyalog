﻿:Class Client
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

    ∇ data←SendRecv req;err;cmd;obj;evt;dat;res
      :Access Public
      data←⍬
      ⍝ we could connect if somebody forgot
      :If ⍬≡name ⋄ _←Connect ⋄ :EndIf
     
      (err cmd)←2↑res←Send req
      :If err≠0
          (⍕res)⎕SIGNAL 11
      :EndIf

      data←Recv cmd      
    ∇

    ∇ res←Send req
      :Access Public
      :If ⍬≡name ⋄ _←Connect ⋄ :EndIf ⍝ Connect if necessary
     
      res←LIB.Send name req     
    ∇                                  
    
    ∇ data←Recv cmd;evt;dat;obj;err
      :Access Public
     
      :Repeat
          (err obj evt dat)←4↑0 Assert LIB.Wait cmd timeout
          :If evt≢'Timeout'
              data←dat
              :Leave
          :EndIf
      :EndRepeat
    ∇

:EndClass
