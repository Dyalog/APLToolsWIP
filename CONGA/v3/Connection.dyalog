:Class Connection
    :field Public srv   ⍝ reference to Server started the Connection
    :field Public Name
    :field Public extra


    ∇ ct←ServerArgs
      :Access Public shared
        ⍝ return the type of connection you want
      ct←,⊂'Command'
    ∇

    ∇ sp←srv ServerProperties name
      :Access Public shared
         ⍝ Return the Properties to set for the server or
         ⍝ use the srv ref to access srv and srv.DRC and do it yourself
      sp←⍬
    ∇

    ∇ e←Progress(obj data)
      :Access public
      e←srv.DRC.Progress obj data
    ∇

    ∇ e←Respond(obj data)
      :Access public
      e←srv.DRC.Respond obj data
    ∇

    ∇ e←Send(data close)
      :Access public
      e←srv.DRC.Send Name data close
    ∇

    ∇ Close obj
      :Access public
      srv.Remove Name
      _←srv.DRC.Close Name
    ∇


    ∇ makeN arg
      :Access public
      :Implements constructor
      enc←{1=≡⍵:⊂⍵ ⋄ ⍵}
      defaults←{⍺,(⍴,⍺)↓⍵}
     
      (Name srv extra)←(enc arg)defaults''⍬(⎕NS'')
    ∇

    ∇ r←Test
      :Access public
      r←42
    ∇

    ∇ onReceive(obj data)
          ⍝:Access public
      :Access public overridable
      Respond obj(⌽data)
    ∇

    ∇ onError(obj data)
          ⍝:Access public
      :Access public overridable
      ⎕←'Oh no ',obj,' has failed with error ',⍕data
    ∇


:EndClass
