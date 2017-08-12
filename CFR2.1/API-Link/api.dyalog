:namespace API
⍝∇:require =Files.dyalog
⍝
⍝ important: all API-Fns must be designed to return
⍝ (0=success, error-code)(error-msg)(result)
⍝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
⍝
⍝
    ∇ R←CallAPI arg;exec;id;⎕TRAP
      ⎕TRAP←0 'S'  ⍝ disable all trapping in outer fns...
     ⍝ Poor man's logging of API-Calls - only useful during dev!
     ⍝ ⎕SE.Dyalog.Utils.disp'CallAPI ⍵='arg
      (id arg)←arg ⋄ arg←{⎕ml←1 ⋄ 1=≡⍵: ⊂⍵ ⋄ ⍵} arg
      exec←((3=≢arg)/'(3⊃arg)'),('iAPI.',1⊃arg),(1<⍴arg)/' 2⊃arg'
      :Trap Trapping/0
          :With id
              R←⍎exec
          :EndWith
      :Else
          R←1(⎕DM)
      :EndTrap
     ⍝ ⎕SE.Dyalog.Utils.disp'CallAPI R='R
    ∇


    ∇ r←mode InitAPI(APIHomeDir API APIClassName APIType APIRequires APIToken sessionId trapping);ns;loadRes;server;port;wsid;runtime;parms
      r←0
      :If mode≡'inSitu'   ⍝############################ inSitu #############################################⍝
          :If 2=⎕NC'#.Boot.AppRoot' ⋄ #.API.⎕CY #.Boot.AppRoot,'API-Link/API-Link' ⋄ :EndIf    ⍝ only needed in "pure" inSitu, APLProcess-inSitu has it alrdy (I just did not want to add a 3d type...)
                ⍝ Set the scene for the API by getting namespaces it needs
          :For ns :In {⎕ML←0 ⋄ 1↓¨(1↓⍵=⍵[1])⊂1↓⍵}',',APIRequires
              :If 0=#.⎕NC ns
                  ⎕SE.SALT.Load APIHomeDir,ns,' -target=#'
              :EndIf
          :EndFor
     
        ⍝ Load configured API either from DWS or .dyalog-file (should do .dyapp, too - probably...later)
          :If '.dws'≡⎕SE.Dyalog.Utils.lcase 3⊃#.Files.SplitFilename API
              #.API.⎕CY API
              loadRes←⍕#.API⍎APIClassName
          :Else
              loadRes←⍕⎕SE.SALT.Load API,' -target=#.API'
          :EndIf
     
          (ns←'#.API.',sessionId)⎕NS''
          #.API.Trapping←trapping
          :If APIType≡'Instance'            ⍝ when running API in instance-mode:
              ⍎ns,'.iAPI←⎕NEW #.API⍎loadRes'⍝ --> create a new instance (we trust that it will work out!)
              ⍝ Classes must support niladic constructor! 
          :ElseIf APIType≡'Shared'          ⍝ Shared methods OR namespace
              ⍎ns,'.iAPI←loadRes'           ⍝ --> a ref to the loaded "thing" will be enough :-)
          :Else
              ('Unknow APIType: ',APIType)⎕SIGNAL 11
          :EndIf
          inSitu←1
      :Else                ⍝############################ Process #############################################⍝
                           ⍝### (mode = Name of Server)
          (server port)←mode
          wsid←#.Boot.AppRoot,'API-Link/api-link'
          runtime←#.Boot.ms.Config.Debug≠2  ⍝ when Debugging is enabled, use interpreter, RT otherwise
          parms←'slave=yes Port=',⍕port          ⍝ 'Path='                              APIPath
          parms,←#.HtmlUtils.enlist(⊂' API'),¨('' 'ClassName' 'HomeDir' 'Type' 'Requires',¨'=',¨(API APIClassName APIHomeDir APIType APIRequires))
          parms,←' autoshut=0 Trapping=',(⍕trapping),' sessionId=',sessionId
          ('#.API.',sessionId)⎕NS''
          #.API.Trapping←trapping
          :With #.API⍎sessionId
              APIProcess←⎕NEW #.APLProcess(wsid parms runtime)
              inSitu←0
          :EndWith
          ⎕DL 10  ⍝ allow some time for the start...
          r←0
     TryAgain:
          :If 0=1⊃r←#.DRC.Clt''server port  ⍝ Connect
              APIConnection←2⊃r
          :Else
              ⎕SE.Dyalog.Utils.display r
              ⎕←'→TryAgain   ⍝ if there is no client-connection...!'
              ∘∘∘No client!∘∘∘   ⍝ this should never happen - but IF it should happen, the → command might be sufficient!
          :EndIf
      :EndIf
    ∇
:endnamespace
