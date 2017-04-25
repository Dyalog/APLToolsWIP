  :Class MyRPC : #.Conga.Connection

        :field Public Methods
        enc←{(326≠⎕dr ⍵)∧  1=≡⍵:,⊂⍵ ⋄ ⍵}

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
             Methods←{↑(⊂¨⍵),¨(⎕AT ⍵)[;1]}   (⎕nl ¯3) ~ (⎕base.⎕nl ¯3),⊂'onReceive'
        ∇
    
        ∇r←TestRPC arg
        :access public
         r←arg+1
        ∇       

        ∇ onReceive(obj data)
          :Access public override 
⍝          :if 0=⎕nc 'Methods'
⍝             Methods←{↑(⊂¨⍵),¨(⎕AT ⍵)[;1]}   (⎕nl ¯3) ~ (⎕base.⎕nl ¯3),⊂'onReceive'
⍝          :endif 
           
           data←enc data

           :If 3<⍴data ⍝ Command is expected to be (function name)(argument)
                _←Respond obj(999 'Bad command format') ⋄ :Return
           :EndIf
           
            Methods[;1]⍳ cmd←1⊃data
           :If (⊃⍴Methods)<fi←Methods[;1]⍳   ⊂cmd←1⊃data ⍝ Command is expected to be a function in this ws
              _←Respond obj(999('Illegal command: ',cmd)) ⋄ :return
           :EndIf
     
           :If (⊃Methods[fi;2])≠¯1+⍴data  ⍝ Number of argument need to match the intance methode
               _←Respond obj(999('Wrong number of arguments: ',cmd)) ⋄ :return
            :EndIf
     
            :Select ⊃⍴data
            :Case 1                
                _←Respond obj   ({0::⎕en ⎕dm⋄ 0 (⍎⊃⍵) } data)      
                  :Case 2
                _←Respond obj  ({0::⎕en ⎕dm⋄ 0 ((⍎1⊃⍵) (2⊃⍵)) } data )     
                :Case 3
                _←Respond obj  ({0::⎕en ⎕dm⋄ 0 ((3⊃⍵) (⍎1⊃⍵) (2⊃⍵)) } data)      
               :Else 
               _←Respond obj (999 'ooh no')
              :EndSelect
        ∇

    :EndClass

