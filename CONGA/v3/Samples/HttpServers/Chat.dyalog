:Class ChatServer : HttpServerBase
    ⍝ Implement a web-socket based
    :Require HttpServerBase

    :field Public shared clients←⍬

    INDEXHTML←'c:\tmp\UM2016\index.html' ⍝ /// This needs to be fixed

    NL←⎕UCS 13 10
    fromJSON←7159⌶
    toJSON←7160⌶

    ∇ sp←srv ServerProperties name
      :Access public shared
      sp←,⊂('WSFeatures' 1)
    ∇

    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
    ∇

    ∇ Unmake
      :Implements destructor
      clients←clients{(~⍺∊⊂⍵)/⍺}Name
    ∇

    ⍝ Return the Html/javascript for Browser to run the chat program
    ∇ onHtmlReq;html;headers;hdr;e
      :Access public override
      headers←0 2⍴⍬
      headers⍪←'Server' 'ClassyDyalog'
      headers⍪←'Content-Type' 'text/html'
      hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
      e←SendFile 0 hdr INDEXHTML
      :If 1039=⊃e
          SendAnswer'404 Not Found'hdr''
      :EndIf
    ∇

    ⍝ If WSFeatures is set to 1 you get a notification when the connection is upgraded
    ∇ onWSUpgrade(obj data)
      :Access Public
      clients,←⊂Name
    ∇
    
    ⍝ if WSFeatures is 0 You have to accept the upgrade requests
    ∇ onWSUpgradeReq(obj data)
      :Access Public
      _←srv.DRC.SetProp Name'WSAccept'(data'')
      clients,←⊂Name
    ∇

    ⍝ When the Browser sent data to the server
    ∇ onWSFText(obj data);code;msg;ns;resp
      :Access Public
      ⎕←data
      code msg←data
           ⍝ns←7159⌶ msg
      ns←fromJSON msg
      ns.date←,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2,<.>,ZI3'⎕FMT⍉⍪⎕TS
          ⍝resp←7160⌶ns
      resp←toJSON ns
      clients{srv.DRC.Send ⍺ ⍵}¨⊂1 resp
    ∇

:EndClass
