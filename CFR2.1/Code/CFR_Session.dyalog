:class CFR_Session
    :field public sessionId←''
    :field public APIConnection
    :field public APIProcess  ⍝ when running inSitu this is the API-Instance used in this session. When API is
                              ⍝ executed in sep. process, it is a ref to the APLProcess that is used to run the API.
    :field public Trapping←0   ⍝ enable error-trapping (1=catch errors (still rudimentary), 0=stop on errors)
    :field private APIToken
    :field private UID   ⍝ a numeric userid (possibly index into user-table)
    :field private tUID  ⍝ UserId in text-format (might be the "real" Userid or name, just something for the UI)
    :field private initialisedAPI←0  ⍝ is it tully "there"?
    :field private server←''
    :field private port←0
	:field private RegData   ⍝ vector of registration data  ⍝ see index.mipage etc. for the contents
⍝ the following fields hold the form info




    ∇ MakeNewSession arg;runtime;parms;wsid;fl
      :Access public
      :Implements constructor
      ⍝ arg=(server)(port)
      ⍝ server ≡ 'inSitu' run stuff in same DWS!
      (server port)←arg
      sessionId←#.HtmlElement.GenId
      APIToken←⎕a[?26],' '~⍨⍕⎕ai ⍝⍝⍝ #.utils.salt 32 ⍝  [*ToDo*]: Integrate & validate this in all exchange with APLProcesses!
    ∇



    ∇ {R}←CallAPI arg;exec;r;sess
      :Access public
          ⍝ arg=
          ⍝   [1] Name of fn
          ⍝   [2] right argument
          ⍝   [3] left argument
          ⍝ R=(RetCode)(Result from API)
          ⍝ RetCode:
          ⍝   0=No problems
          ⍝   1=Error executing API-CallAPI'arg
          ⍝   2=Error returned by API
      arg←#.HtmlUtils.eis arg
      :If ~initialisedAPI
          :If 0=#.⎕NC'API'  ⍝ if #.API does not exist, create it and fill with ws as required
              ⎕SE.SALT.Load #.Boot.AppRoot,'API-Link/API',' -target=#'
          :EndIf
          :If server≡'inSitu'
              APIConnection←sessionId,'.inSitu'
              'inSitu'#.API.InitAPI(#.Boot.ms.Config.Application.(APIHomeDir API APIClassName APIType APIRequires),(APIToken sessionId Trapping))
          :Else
              r←(server port)#.API.InitAPI(#.Boot.ms.Config.Application.(APIHomeDir API APIClassName APIType APIRequires),(APIToken sessionId Trapping))
              :If 0=⊃r
                  APIConnection←2⊃r
              :EndIf
     
          :EndIf
          ('#.API.',sessionId)⎕NS'APIToken'
          #.API.Trapping←Trapping
          initialisedAPI←1
          r∆←CallAPI'Init'#.Boot.ms.Config.Application.APIDataDir
     
      :EndIf
     
      :Trap Trapping/0
          :If (#.HtmlUtils.eis arg)≡,⊂'∇CloseAPI∇'      ⍝ [*Question*] Explicit command to close API - or use class-destructor instead?
              r←0
              :If '.inSitu'≡¯7↑APIConnection
                  #.API.⎕EX sessionId
                  R←0
              :Else
                  R←RPCGet APIConnection('#.API.CallAPI'(sessionId arg))
              :EndIf
          :ElseIf '.inSitu'≡¯7↑APIConnection
              sess←{(∧\~'.inSitu'⍷⍵)/⍵}sessionId
              R←#.API.CallAPI(sess arg)
          :Else
              R←RPCGet APIConnection('#.API.CallAPI'(sessionId arg))
              :If 0=⍬⍴R
                  R←4 2⊃R
              :EndIf
          :EndIf
      :Else
          R←1(⎕DM)
      :EndTrap
    ∇

    ∇ {r}←RPCGet(client cmd);c;done;wr;z
   ⍝ Send a command to an RPC server (on an existing connection) and wait for the answer.
     
      res←#.DRC.Send client cmd
      :If 2≠⍴res
          ⎕TRAP←0 'S'
      :EndIf
      :If 0=1⊃(r c)←res
          :Repeat
              :If ~done←∧/100 0≠1⊃r←#.DRC.Wait c 10000 ⍝ Only wait 10 seconds
     
                  :Select 3⊃r
                  :Case 'Error'
                      done←1
                  :Case 'Progress'
  ⍝ progress report - update your GUI with 4⊃r?
                      ⎕←'Progress: ',4⊃r
                  :Case 'Receive'
                      done←1
                  :EndSelect
              :EndIf
          :Until done
      :EndIf
    ∇


:endclass
