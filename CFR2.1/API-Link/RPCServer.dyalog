:Namespace RPCServer
    (⎕IO ⎕ML)←1 1
    SendProgress←0
    Protocol←''      ⍝ Set to IPv4 or IPv6 to lock in
    StartTime←⎕TS
    Commands←Errors←CPU←0
    ß←{} ⍝ stub "fake" function to allow stats reporting

    ∇ r←GetEnv name;args;z
     ⍝ Look for environment settings, allowing Command Line overrides
     ⍝ Added to support isolates as bound executables under Windows
     
      :If 1=⍴z←name{(((1+≢⍺)↑¨⍵)∊⊂⍺,'=')/⍵}2 ⎕NQ'.' 'GetCommandLineArgs'
          r←(1+⍴name)↓⊃z
      :Else
          r←2 ⎕NQ'.' 'GetEnvironment'name
      :EndIf
    ∇
 
    ∇ r←{folder}Launch(params port);z;folder;ws
    ⍝ Launch RPC Server as an external process
    ⍝ Params should include -Load=
    ⍝ See Boot for additional parameters
    ⍝ RPCServer.dyalog and RPCServer.dws must exist in same folder as current ws
    ⍝ /// Currently Windows only ///
     
      :If 0=⎕NC'folder' ⋄ folder←{(1-⌊/(⌽⍵)⍳'/\')↓⍵}⎕WSID ⋄ :EndIf
      ws←'"',folder,'RPCServer.DWS"'
      params←params,' Port=',⍕port
      r←⎕NEW #.APLProcess(ws params)
    ∇

    ∇ r←DNSLookup args;port;address;noport
    ⍝ r[;1] protocol, [;2] address txt, [;3] numeric address, [;4] port
    ⍝ /// Should really make its way into DRC
     
      :If noport←1=≡args ⋄ args←args 80 ⋄ :EndIf
      (address port)←args
      :If 1037=⊃r←##.DRC.GetProp'.' 'tcplookup'address port
          r←##.DRC.GetProp'.' 'lookup'address port ⍝ name changed around Conga 2.5.22481
      :EndIf
      (⍕r)⎕SIGNAL(0≠1⊃r)⍴11
      r←(-noport)↓⍤1↑2⊃r
      r[;2]←((-(⍳∘':'⌽)¨r[;2]))↓¨r[;2]
    ∇

    ∇ Boot;name;port;certfile;keyfile;sslflags;num;secure;load;l;folder;z;autoshut;quiet;allowremote;commasep;localaddrs
    ⍝ Bootstrap an RPC-Server using the following command line parameters
    ⍝ -Port=nnnn
    ⍝ -Load=.dyalog files to load before start
    ⍝ -AllowRemote=filter1,filter2,filter3
    ⍝ SSL Options
    ⍝ -CertFile=CertFile
    ⍝ -KeyFile=KeyFile
    ⍝ -SSLFlags=flags
    ⍝ /// Could be extended with
    ⍝ -Config=name of a configuration file
    ⍝ -ClientAddr=limit to connections from given site
     
      folder←{(1-⌊/(⌽⍵)⍳'/\')↓⍵}⎕WSID
      num←{⊃2⊃⎕VFI ⍵}
      sslflags←32+64 ⍝ Accept without Validating, RequestClientCertificate
     
      name←'RPCSRV'
      port←num GetEnv'Port'
      autoshut←num GetEnv'AutoShut' ⍝ Shut down if 1st connection is lost
      quiet←num GetEnv'Quiet'       ⍝ Suppress diagnostic session output
      allowremote←''                ⍝ No remote access
     
      z←##.DRC.Init''
      localaddrs←⊃⍪/{0::0 3⍴⊂⍬ ⋄ DNSLookup ⍵}¨'' 'localhost' ⍝ Find all local addresses
      :If 0=≢localaddrs ⍝ /// paranoia: the above SHOULD work
          localaddrs←1 3⍴'IPv4' '127.0.0.1'(127 0 0 1)
      :EndIf
     
      ⎕←'local:' ⋄ ⎕←localaddrs
     
      :If 0≠⍴load←GetEnv'Load'
          load←{1↓¨(','=⍵)⊂⍵}',',load
          :For l :In load
              ⎕SE.SALT.Load folder,l,' -target=#'
          :EndFor
      :EndIf
     
      :If secure←0≠⍴certfile←GetEnv'CertFile'
          keyfile←GetEnv'KeyFile'
          sslflags←num GetEnv'SSLFlags'
          z←1 quiet autoshut Run name port('CertFile'certfile)('KeyFile'keyfile)('SSLFlags'sslflags)
      :Else
          z←1 quiet autoshut Run name port
      :EndIf
     
      :If 0≠1⊃z ⋄ ⎕←z ⋄ ⎕DL 10 ⋄ :EndIf ⍝ /// Pop up? Log?
     
      :While ##.DRC.Exists name
          ⎕DL 10
      :EndWhile
     
      ⎕OFF
    ∇

    ∇ r←End x
      r←done←x ⍝ Will cause server to shut down
    ∇

    ∇ r←AllowRemoteAccess filters;i
     ⍝ By default, RPCServer will only accept connections from the local machine
     ⍝ /// validation?
     
      r←filters
     
      :If 0=⍴allowremote←r
          ⎕←'Local access only'
      :Else
          ⎕←'Remote access allowed for ',,⍕filters
      :EndIf
    ∇

    ∇ Process(obj data);r;c
      ⍝ Process a call. data[1] contains function name, data[2] an argument
     
      :If SendProgress
          {}##.DRC.Progress obj('    Thread ',(⍕⎕TID),' started to run: ',,⍕data) ⍝ Send progress report
      :EndIf
      ⎕TRAP←0 'S'  ⍝ temporary...
      :If (,1⊃data)≡,'ß' ⍝ stats collection?
          r←(0(StartTime Commands Errors CPU))
      :Else
          ⍝:Trap 0 ⋄ c←⎕AI[3] ⋄ r←0((⍎1⊃data)(2⊃data)) ⋄ CPU+←⎕AI[3]-c ⋄ Commands+←1
          :Trap 0/0 ⋄ c←⎕AI[3] ⋄ r←0((⍎1⊃data)(2⊃data)) ⋄ CPU+←⎕AI[3]-c ⋄ Commands+←1
          :Else ⋄ r←⎕EN ⎕DM ⋄ Errors+←1
          :EndTrap
      :EndIf
     
      :Trap 11
          {}##.DRC.Respond obj r
      :Else
          {}##.DRC.Respond obj(99999('Unable to return result: ',⎕DMX.Message))
      :EndTrap
    ∇

    ∇ r←{start}Run args;sink;done;data;event;obj;rc;wait;z;cmd;name;port;protocol;srvparams;msg;rt;quiet;autoshut;tid;addr;ok;i;filter;first
      ⍝ Run a Simple RPC Server
     
      (name port)←2↑args
      srvparams←2↓args
     
      :If 0=⎕NC'start' ⋄ start←1 ⋄ :EndIf         ⍝ start may be (start quiet)
      rt←'R'∊'.'⎕WG'APLVersion'                   ⍝ Runtime or DLLRT
      (start quiet autoshut)←0 rt 0∨3↑start
      {}##.DRC.Init''
      :If (⊂Protocol)∊'IPv4' 'IPv6' ⋄ ##.DRC.SetProp'.' 'Protocol'Protocol ⋄ :EndIf
     
      :If start
          :If 0≠1⊃r←##.DRC.Srv(name''port'Command'),srvparams ⋄ :Return ⋄ :EndIf ⍝ Exit if unable to start server
          :If ~rt ⋄ tid←0 quiet autoshut Run&name port
          ⍝ Above line may start handler on separate thread
          ⍝ /// Looks like a bug to Morten if your application is in a runtime
          ⍝ /// That should probably only be done if BOOTING in a runtime
              ⍪quiet↓⊂'Server ''',name,''', listening on port ',⍕port
              ⍪quiet↓⊂' Handler thread started: ',⍕tid
              r←0 tid
              :Return ⍝ New TID
          :EndIf
      :EndIf
     
      ⍝ Handle the server (maybe in a new thread)
      ⍪quiet↓⊂'Thread ',(⍕⎕TID),' is now handling server ''',name,'''.'
      done←0 ⍝ Done←1 in function "End"
      first←''
     
      :While ~done
          :Trap 1002 1003 ⍝ trap weak and strong interrupts - on UNIX kill -2 and kill -3
     
              rc obj event data←4↑wait←##.DRC.Wait name 10000 ⍝ Time out now and again
     
              :Select rc
              :Case 0
                  :Select event
                  :Case 'Error'
                      ⍪quiet↓⊂'Error ',(⍕data),' on ',obj
                      :If ~done∨←name≡obj ⍝ Error on the listener itself?
                          {}##.DRC.Close obj ⍝ Close connection in error
                      :EndIf
     
                      :If autoshut=1
                      :AndIf 0=#.DRC.Exists first
                          ⍪quiet↓⊂'First connection lost - AutoShut initiated'
                          done←1 ⋄ autoshut←2
                      :EndIf
     
                  :Case 'Receive'
                      :If 2≠⍴data ⍝ Command is expected to be (function name)(argument)
                          {}##.DRC.Respond obj(99999 'Bad command format') ⋄ :Leave
                      :EndIf
     
                      :If 3≠⎕NC cmd←1⊃data ⍝ Command is expected to be a function in this ws
                          {}##.DRC.Respond obj(99999('Illegal command: ',cmd)) ⋄ :Leave
                      :EndIf
     
                      Process&obj data ⍝ Handle each call in new thread
     
                  :Case 'Connect' ⍝ Set 'KeepAlive' to 10 seconds so we discover IP disconnections
                      first,←(0=⍴first)/obj ⍝ bond to parent
                      {}##.DRC.SetProp obj'KeepAlive' 10000 10000
                      addr←{(-(⌽⍵)⍳':')↓⍵}2 2⊃##.DRC.GetProp obj'PeerAddr'
                      :If ~ok←(⊂addr)∊localaddrs[;2] ⍝ remote
                          :For i :In ⍳≢allowremote
                              :Select 3↑filter←i⊃allowremote
                              :CaseList 'ip=' 'IP=' ⍝ ip address
                                  :If ok←ok∨addr{⍵≡(⍴⍵)↑⍺}3↓filter ⋄ :Leave ⋄ :EndIf
                              :EndSelect
                          :EndFor
     
                      :AndIf ~ok ⍝ Still not OK
                          ⎕←'Connection refused from: ',addr
                          {}##.DRC.Close obj ⍝ 'bye
                      :EndIf
     
                  :Else ⍝ Unexpected result? should NEVER happen
                      ⎕←'Unexpected result "',event,'" from object "',name,'" - RPC Server shutting down' ⋄ done←1
     
                  :EndSelect
     
              :Case 100  ⍝ Time out - Insert code for housekeeping tasks here
     
              :Case 1010 ⍝ Object Not Found
                  ⎕←'Server object ''',name,''' has been closed - RPC Server shutting down' ⋄ done←1
     
              :Else
                  ⎕←'Error in RPC.Wait: ',⍕wait
              :EndSelect
          :Else ⍝ got an interrupt
              ⎕←((1002 1003⍳⎕EN)⊃'Weak' 'Strong' 'Unknown?'),' interrupt received, RPC Server shutting down'
              done←1
          :EndTrap
      :EndWhile
      :If autoshut≠2 ⋄ ⎕DL 1 ⋄ :EndIf ⍝ Give responses time to complete
      {}##.DRC.Close name
      ⍪quiet↓⊂'Server ',name,' terminated.'
    ∇

:EndNamespace
