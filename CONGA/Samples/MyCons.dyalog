:Namespace MyCons   

    :Class MyCon : #.DRCShared.Connection

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
         
        ∇
 
 
        ∇ onReceive(obj data)
          :Access public override
          _←Respond obj(data(⌽data))
        ∇

    :EndClass 

    :Class MyRPC : MyCon
        :field Public Methods
        enc←{(326≠⎕dr ⍵)∧  1=≡⍵:,⊂⍵ ⋄ ⍵}

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
             Methods←{↑(⊂¨⍵),¨(⎕AT ⍵)[;1]}   (⎕nl ¯3) ~ (⎕base.⎕nl ¯3),⊂'onReceive'
        ∇

    
        ∇r← TestRPC arg
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

    :Class MyConThread : #.DRCShared.Connection

        ∇ sp←srv ServerProperties name
          :Access Public Shared
          sp←,⊂'OnlyConnections' 1
        ∇
    

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
          done←0
          HError←0
          name←⊃arg
          DRC←srv.DRC
          timeout←srv.timeout
          htid←Handler&name         
        ∇
     
        ∇ onReceive(obj data)
          :Access public override
          Respond obj(data(⌽data))
        ∇
  
        ∇ Remove name
          srv.Remove name
        ∇

        ∇ Handler name;r;newcon;err;obj;evt;data
          events←2↓¨'on'{((⊂⍺)≡¨(⍴,⍺)↑¨⍵)/⍵}⎕NL ¯3
          :While !done
              :If 0=⊃r←DRC.Wait name timeout
                  (err obj evt data)←4↑r
                  :Select evt
                  :CaseList 'Error' 'Close'
                      :If 0<⎕NC'onError'
                          onError obj data
                      :EndIf
                      :Leave
         
                  :Case 'Receive'
                      onReceive obj data
                  :Case 'Timeout'
                      :If 0<⎕NC'onTimeout'
                          onTimeout
                      :EndIf
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
          Remove name
        ∇

    :EndClass                           

    :Class HttpCon : #.DRCShared.Connection
        :field Public Version
        :field Public Headers
        :field Public Input
        :field Public Command
        :field Public Page
        :field Public Arguments
        :field Public Body

        NL←(⎕ucs 13 10)

        ∇ sa←ServerArgs
          :Access public shared
          sa←('mode' 'Http')('BufferSize' 1000000)
        ∇

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
          Version←'HTTP/1.0'
          Body←⍬
        ∇
 
        ∇ onHTTPHeader(obj data)
          :Access public
          DecodeCmd data
          datalen←⊃(GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
          chunked←∨/'chunked'⍷GetValue'Transfer-Encoding' ''
          done←(~chunked)∧datalen<1
          :If done
              onHtmlReq
          :EndIf
        ∇

        ∇ onHTTPBody(obj data)
          :Access public
          Body←data
          onHtmlReq
        ∇

        ∇ onHTTPChunk(obj data)
          :Access public
          Body,←data
        ∇

        ∇ onHTTPTrailor(obj data)
          :Access public
          onHtmlReq
        ∇


        ∇ onReceive(obj data)
          :Access public override 
          'HttpMode'⎕SIGNAL 999
        ∇
    
        ∇ onHtmlReq
          :Access public overridable
          _←SendAnswer 0 ''('You are asking for ',Page)
        ∇
    
        eis←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵} ⍝ enclose if simple
        getHeader←{(⍺[;2],⊂'')⊃⍨⍺[;1]⍳eis ⍵}
        addHeader←{0∊⍴⍺⍺ getHeader ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺}
        makeHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵}
        fmtHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:'' ⋄ ∊{NL,⍨(1⊃⍵),': ',⍕2⊃⍵}¨↓⍵}
    
        ∇ d←HttpDate
          d←2⊃srv.DRC.GetProp'.' 'HttpDate'
        ∇
     
        ∇ e←SendAnswer(status hdr content);Answer
          :Access public
          hdr←'Date: ',HttpDate,NL,hdr
          :If 0≡status ⋄ status←'200 OK' ⋄ :EndIf
          :If 0≠⍴hdr ⋄ hdr←(-+/∧\(⌽hdr)∊NL)↓hdr ⋄ :EndIf
          Answer←(uc Version),' ',status,NL,((0<⍴content)/'Content-Length: ',(⍕⍴content),NL),hdr,NL,NL
          Answer←Answer,content
          e←Send Answer(Version≡'http/1.0')
        ∇

        ∇ e←SendFile(status hdr filename);Answer
          :Access public
          hdr←'Date: ',HttpDate,NL,hdr
          :If 0≡status ⋄ status←'200 OK' ⋄ :EndIf
          :If 0≠⍴hdr ⋄ hdr←(-+/∧\(⌽hdr)∊NL)↓hdr ⋄ :EndIf
          Answer←(uc Version),' ',status,NL,hdr,NL,NL
          e←Send (Answer filename) (Version≡'http/1.0')
        ∇
             
        ∇ DecodeCmd req;split;buf;input;args;z
     ⍝ Decode an HTTP command line: get /page&arg1=x&arg2=y
     ⍝ Return namespace containing:
     ⍝ Command: HTTP Command ('get' or 'post')
     ⍝ Headers: HTTP Headers as 2 column matrix or name/value pairs
     ⍝ Page:    Requested page
     ⍝ Arguments: Arguments to the command (cmd?arg1=value1&arg2=value2) as 2 column matrix of name/value pairs
         
          input←1⊃,req←2⊃DecodeHeader req
          'HTTPCmd'⎕NS'' ⍝ Make empty namespace
          Input←input
          Headers←{(0≠⊃∘⍴¨⍵[;1])⌿⍵}1 0↓req
         
          split←{p←(⍺⍷⍵)⍳1 ⋄ ((p-1)↑⍵)(p↓⍵)} ⍝ Split ⍵ on first occurrence of ⍺
         
          Version←⌽⊃' 'split⌽input
          Command buf←' 'split input
          buf z←'http/'split buf
          Page args←'?'split buf
         
          Arguments←(args∨.≠' ')⌿↑'='∘split¨{1↓¨(⍵='&')⊂⍵}'&',args ⍝ Cut on '&'
        ∇
         
        ∇ r←DecodeHeader buf;len;d;dlb;i
⍝ Decode HTML Header
          r←0(0 2⍴⊂'')
          dlb←{(+/∧\' '=⍵)↓⍵} ⍝ delete leading blanks
          :If 0<i←⊃{((NL,NL)⍷⍵)/⍳⍴⍵}buf
              len←(¯1+⍴NL,NL)+i
              d←(⍴NL)↓¨{(NL⍷⍵)⊂⍵}NL,len↑buf
              d←↑{((p-1)↑⍵)((p←⍵⍳':')↓⍵)}¨d
              d[;1]←lc¨d[;1]
              d[;2]←dlb¨d[;2]
              r←len d
          :EndIf
        ∇
        ∇ r←lc x;t
          t←⎕AV ⋄ t[⎕AV⍳⎕A]←'abcdefghijklmnopqrstuvwxyz'
          r←t[⎕AV⍳x]
        ∇

        ∇ r←uc x;t
          t←⎕AV ⋄ t[⎕AV⍳'abcdefghijklmnopqrstuvwxyz']←⎕A
          r←t[⎕AV⍳x]
        ∇

        ∇ r←GetValue(name type);i;h
     ⍝ Extract value from HTTP Header structure returned by DecodeHeader
         
          :If (1↑⍴Headers)<i←Headers[;1]⍳⊂lc name
              r←⍬ ⍝ Not found
          :Else
              r←⊃Headers[i;2]
              :If 'Numeric'≡type
                  r←1⊃2⊃⎕VFI r
              :EndIf
          :EndIf
        ∇

    :EndClass    

    :class HtmlReq: HttpCon   
        NL←⎕UCS 13 10
        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
        ∇
    
        ∇ onHtmlReq;html;headers;hdr;e
          :Access public override 
          html←'<!DOCTYPE html><html><head><title>Page Title</title></head><body><h1>Requesting: ',Page,'</h1><p>',(Table Headers),'</p></body></html>'
          headers← 0 2 ⍴⍬
          headers⍪←'Server' 'ClassyDyalog'
          headers⍪←'Content-Type' 'text/html'
          hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
          e←SendAnswer 0 hdr html
        ∇

        ∇ r←{options}Table data;NL
     ⍝ Format an HTML Table
         
          NL←⎕AV[4 3]
          :If 0=⎕NC'options' ⋄ options←'' ⋄ :EndIf
         
          r←,∘⍕¨data                     ⍝ make strings
          r←,/(⊂'<td>'),¨r,¨⊂'</td>'     ⍝ enclose cells to make rows
          r←⊃,/(⊂'<tr>'),¨r,¨⊂'</tr>',NL ⍝ enclose table rows
          r←'<table ',options,'>',r,'</table>'
        ∇

    :endclass    
       
    :class HtmlReqSecure:HttpCon
        NL←⎕UCS 13 10

        ∇ MakeN arg;err
          :Access Public
          :Implements Constructor :Base arg
          
          (err Certs)←srv.DRC.GetProp Name 'PeerCert'
          :if err=0
          :andif 9=⎕nc 'Certs'
            Certs.Chain.Formatted.(Issuer Subject)
          :endif
        ∇ 
        
        ∇ sa←ServerArgs
          :Access public shared
          sa←('mode' 'Http')('BufferSize' 1000000) 
          sa,←⊂   ('PublicCertFile' ('DER' 'C:\apps\dyalog150U64\TestCertificates\server\localhost-cert.pem'))
          sa,←⊂ ('PrivateKeyFile' ('DER' 'C:\apps\dyalog150U64\TestCertificates\server\localhost-key.pem'))
          sa,←⊂  ('SSLValidation' (64+128)) 
         ⍝ sa,←⊂ ('Priority' 'SECURE128:+SECURE192:-VERS-ALL:+VERS-TLS1.1')
        ∇
        
       ∇ sp←srv ServerProperties name
          :Access Public shared
         ⍝ Return the Properties to set for the server or
         ⍝ use the srv ref to access srv and srv.DRC and do it yourself
          _←srv.DRC.GetProp'.' 'RootCertDir'  'C:\apps\dyalog150U64\TestCertificates\ca\'
          _←srv.DRC.SetProp '.' 'TraceGNUTls' 99
          _←srv.DRC.SetProp '.' 'Trace' (1024+8)

          sp←⍬
        ∇
          
          
        ∇r←DecodeCert c   
         asText←{'UTF-8' ⎕UCS ⎕ucs ⍵}
         split←{(⍴,⍺)↓¨ (⍺⍷⍺,⍵)⊂⍺,⍵}
         toMat←{ ↑'=' split¨ ',' split ⍵ }
         r←toMat ¨asText¨ ↑c.Formatted.(Subject Issuer) 
        ∇        
                    
        ∇ onHtmlReq;html;headers;hdr;e
          :Access public override             
          ...
          html←'<!DOCTYPE html><html><head><title>Page Title</title></head><body><h1>Requesting: ',Page,'</h1><p>',(Table Headers),'</p>',(Table ↑ Certs.Chain.Formatted.(Issuer Subject) ) ,'</body></html>'
          headers← 0 2 ⍴⍬
          headers⍪←'Server' 'ClassyDyalog'
          headers⍪←'Content-Type' 'text/html'
          hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
          e←SendAnswer 0 hdr html
        ∇

        ∇ r←{options}Table data;NL
     ⍝ Format an HTML Table
         
          NL←⎕AV[4 3]
          :If 0=⎕NC'options' ⋄ options←'' ⋄ :EndIf
         
          r←,∘⍕¨data                     ⍝ make strings
          r←,/(⊂'<td>'),¨r,¨⊂'</td>'     ⍝ enclose cells to make rows
          r←⊃,/(⊂'<tr>'),¨r,¨⊂'</tr>',NL ⍝ enclose table rows
          r←'<table ',options,'>',r,'</table>'
        ∇
        

    :endclass   
       

    :class HtmlReqStatic: HttpCon   
        NL←⎕UCS 13 10   
        dtb←{                                           ⍝ Drop Trailing Blanks.
     ⍺←' ' ⋄ 1<|≡⍵:(⊂⍺)∇¨⍵                       ⍝ nested?
     2<⍴⍴⍵:(¯1↓⍴⍵){(⍺,1↓⍴⍵)⍴⍵}⍺ ∇,[¯1↓⍳⍴⍴⍵]⍵     ⍝ array
     1≥⍴⍴⍵:(-+/∧\⌽⍵∊⍺)↓⍵                         ⍝ vector
     (~⌽∧\⌽∧⌿⍵∊⍺)/⍵                              ⍝ matrix
 }

        ∇ct←ContentType page;ext;list
          list ← 2 2 ⍴'pdf' 'application/pdf' 'txt' 'text/html'
         
          ext← dtb  {(1-(⌽⍵)⍳'.')↑⍵ }page 
          
        ct←⊃(list[;2],⊂'text/html')[    list[;1]⍳⊂ext]
        ∇

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
        ∇
    
        ∇ onHtmlReq;html;headers;hd;e
          :Access public override 
          headers← 0 2 ⍴⍬
          headers⍪←'Server' 'ClassyDyalog'
          headers⍪←'Content-Type' (ContentType Page)
          hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
          e←SendFile 0 hdr ('c:\tmp\',Page)
          :if 1039=⊃e
               SendAnswer '404 Not Found' hdr ''
          :endif
        ∇

        ∇ r←{options}Table data;NL
     ⍝ Format an HTML Table
         
          NL←⎕AV[4 3]
          :If 0=⎕NC'options' ⋄ options←'' ⋄ :EndIf
         
          r←,∘⍕¨data                     ⍝ make strings
          r←,/(⊂'<td>'),¨r,¨⊂'</td>'     ⍝ enclose cells to make rows
          r←⊃,/(⊂'<tr>'),¨r,¨⊂'</tr>',NL ⍝ enclose table rows
          r←'<table ',options,'>',r,'</table>'
        ∇

    :endclass   
    
    
    
    :class  Chat : HttpCon
        :field Public shared clients←⍬
         
        NL←⎕UCS 13 10
        fromJSON←7159⌶                                                                    
        toJSON←7160⌶

        ∇ sp←srv ServerProperties name
          :Access public shared
          sp←,⊂ ('WSFeatures' 1)
        ∇

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg  
        ∇

        ∇Unmake
        :implements destructor
          clients←clients {(~⍺∊⊂⍵)/⍺ } Name
        ∇  
        
        ⍝ Return the Html/javascript for Browser to run the chat program 
        ∇ onHtmlReq;html;headers;hdr;e
          :Access public override 
          headers← 0 2 ⍴⍬
          headers⍪←'Server' 'ClassyDyalog'
          headers⍪←'Content-Type' 'text/html'
          hdr←(-⍴NL)↓⊃,/{⍺,': ',⍵,NL}/headers
          e←SendFile 0 hdr ('c:\tmp\UM2016\index.html')
          :if 1039=⊃e
               SendAnswer '404 Not Found' hdr ''
          :endif
        ∇
        
        ⍝ If WSFeatures is set to 1 you get a notification when the connection is upgraded
        ∇onWSUpgrade (obj data)
        :access Public 
         clients,←⊂Name
        ∇
        ⍝ if WSFeatures is 0 You have to accept the upgrade requests
        ∇onWSUpgradeReq (obj data)
        :access Public 
         _←srv.DRC.SetProp Name 'WSAccept' (data'')
         clients,←⊂Name
        ∇
        
        ⍝ When the Browser sent data to the server
        ∇onWSFText (obj data);code;msg;ns;resp 
        :access Public  
           ⎕←data
           code msg←data
           ⍝ns←7159⌶ msg
           ns←fromJSON msg
           ns.date←,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2,<.>,ZI3'⎕FMT⍉⍪⎕TS
          ⍝resp←7160⌶ns
          resp←toJSON ns
           clients{srv.DRC.Send ⍺ ⍵}¨⊂1 resp
        ∇

    :endclass
    
             
      :Class MyText : #.DRCShared.Connection

         ∇ sa←ServerArgs
          :Access public shared
          sa←('mode' 'Text')('BufferSize' 1000000)('EOM' '</EOM>' )('IgnoreCase' 1)
        ∇



        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
         
        ∇
 
 
        ∇ onBlock(obj data)
          :Access public 
          _←Send (⌽data)0
        ∇

    :EndClass 
           
⍝       :class UdpCon:#.DRCShared.Connection
⍝   
⍝        ∇ MakeN arg;err
⍝          :Access Public
⍝          :Implements Constructor :Base arg
⍝          
⍝   
⍝        ∇ 
⍝        
⍝        ∇ sa←ServerArgs
⍝          :Access public shared
⍝          sa←('mode' 'udp')('BufferSize' 10000) 
⍝          sa,←⊂  ('Protocol' 'ipv4')
⍝        ∇
⍝        
⍝       ∇ sp←srv ServerProperties name
⍝          :Access Public shared
⍝         ⍝ Return the Properties to set for the server or
⍝         ⍝ use the srv ref to access srv and srv.DRC and do it yourself
⍝          sp←⍬
⍝        ∇
⍝          
⍝                             
⍝        ∇ onBlock (obj data)
⍝          :Access public override             
⍝          _←srv.DRC.Send obj (⌽data)
⍝        ∇
⍝        
⍝    :endclass         

:EndNamespace
