⍝!:require file://HttpServerBase.dyalog
:Class ChatServer : HttpServerBase

    ⍝ Implement a web-socket based chat server

    :Field Public Shared clients←⍬

    NL←⎕UCS 13 10

    ∇ sp←srv ServerProperties name
      :Access Public Shared
      sp←,⊂('WSFeatures' 1) ⍝ Auto-accept WebSocket upgrade requests
    ∇

    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
     
      DIR←1⊃⎕nparts 4⊃5179⌶ '#.ChatServer'
      INDEXHTML←DIR,'chat.html'
      :If ~⎕NEXISTS INDEXHTML
          ('Index page "',INDEXHTML,'" not found')⎕SIGNAL 2
      :EndIf
    ∇

    ∇ Unmake
      :Implements Destructor
      clients←clients{(~⍺∊⊂⍵)/⍺}Name
    ∇

    ⍝ Return the Html/javascript for Browser to run the chat program
    ∇ onHtmlReq;html;headers;hdr;e
      :Access Public Override
      ⎕←'|',Page,'|'
      headers←0 2⍴⍬
      headers⍪←'Server' 'ClassyDyalog'
      headers⍪←'Content-Type' 'text/html'
      :Select Page~' /'
      :Case '' ⋄ file←INDEXHTML
      :Case 'jquery-3.2.1.min.js'
          file←(1⊃⎕NPARTS INDEXHTML),Page
          headers[2;2]←⊂'application/javascript'
      :EndSelect
      hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
      file←∊1 ⎕NPARTS file
      e←SendFile 0 hdr file
    ∇

    ⍝ If WSFeatures is set to 1 you get a notification when the connection is upgraded
    ∇ onWSUpgrade(obj data)
      :Access Public
      clients,←⊂Name
     ⍝ ⎕←'onWSUpgrade' ⋄ obj data
    ∇

    ⍝ if WSFeatures is 0 You have to accept the upgrade requests
    ∇ onWSUpgradeReq(obj data)
      :Access Public
      _←srv.DRC.SetProp Name'WSAccept'(data'')
      clients,←⊂Name
      ⎕←'onWSUpgradeReq' ⋄ obj data clients
    ∇

    ⍝ When the Browser sent data to the server

    ∇ onWSReceive(obj data);code;msg;ns;resp;final;opcode
      :Access Public
     
      ⎕←(msg final opcode)←data
      ⎕←clients
      ns←{2::7159⌶⍵ ⋄ ⎕JSON ⍵}msg
      ns.date←,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2,<.>,ZI3'⎕FMT⍉⍪⎕TS
      resp←{2::7160⌶⍵ ⋄ ⎕JSON ⍵}ns
      sendTo←clients{⍺[(⍳≢⍺)~2⊃⎕vfi ¯1↑⍵]}(⎕json resp).handle  ⍝ find the "other" connection (lame & stupid code, I know)
      {}sendTo{srv.LIB.Send ⍺ ⍵}¨⊂resp 1
    ∇

:EndClass
