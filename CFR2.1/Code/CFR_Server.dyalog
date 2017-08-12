:class CFR_Server : MiServer
    :field private path←''  ⍝ the API-Home-Directory...


    ∇ onServerStart
      :Access public  Override
      #.Boot.ms.Config.Application←#.Boot.ReadConfiguration'Application'
      InitAPIServerCfg #.Boot.ms.Config.Application
      #.⎕ex'Countries'
      #.⎕fix 'file://',#.Boot.AppRoot,'/Code/Countries.dyalog'   ⍝ silly fix to circumvent 5177⌶ problems
    ∇

    ∇ InitAPIServerCfg ref;t;ns1
      :Access private
    ⍝ Initialise Server-Config in namespace ref by
    ⍝ re-formatting some variables
      :With ref
        ⍝ API_Ports: numeric vector of possible port-numbers
          API_Ports←#.HtmlUtils.enlist 2⊃¨⎕VFI¨','#.Utils.penclose API_Ports
        ⍝ API_Hosts: list of all hosts (currently APLProcess only works on current machine, future updates might make it work with remote machines as well)
          API_Hosts←⊂¨','#.Utils.penclose API_Hosts
        ⍝ IPsPorts is the list of all hosts, ports and a flag whether a combo is active or not (to quickly find available combinations)
          IPsPorts←↑,⍉API_Hosts∘.,API_Ports    ⍝ [;1] Host, [;2]=Port  ⍝ ⍉ ensures "load-balancing" across all involved machines! (primitve lb, at least)
          IPsPorts,←0                          ⍝ [;3] is active
      :EndWith
     
      path←ref.APIHomeDir←FixPath ref.APIHomeDir  ⍝ make sure specified paths do exist: home-directory for API
      ref.APIDataDir←FixPath ref.APIDataDir       ⍝ and its Data-directory
     
      t←#.Boot.ms.Config.Application.API←path,#.Boot.ms.Config.Application.API
      :If 0=⍴,t
          'Invalid File-Specification in parameter API'⎕SIGNAL 22
      :ElseIf ~#.Files.Exists t
          ('API-File not found! <',t,'>')⎕SIGNAL 22
      :EndIf
    ∇

    ∇ path←FixPath path
     ⍝ fix path specification (make sure there's a trailing slash and replace "./" with AppRoot...)
     ⍝ also signals an error if path is not laid (does not exist)
      path,←(~∨/'\/'∊¯1↑path)/'/'
      :If './'≡2↑path
          path←1⊃#.Files.SplitFilename #.Boot.AppRoot,2↓path
      :EndIf
      ('Path <',path,'> does not exist!')⎕SIGNAL 22/⍨~#.Files.DirExists path
    ∇

    ∇ make1 R
      :Access public
      :Implements constructor :Base R
    ∇

    ∇ onSessionStart req;wsid;ns1;ns2;pt;rq
      :Access Public Override
    ⍝ Process a new session
      req.Session.(APIServer port)←GetHostAndPort Config.Application
      req.Session.APIref←⎕NEW #.CFR_Session req.Session.(APIServer port)
      req.Session.Country←'GB' ⍝ 'country_code'#.Countries.FromIP{(¯1+⍵⍳':')↑⍵}2⊃req.PeerAddr 
    ∇

    ∇ onSessionEnd session
      :Access Public Overridable
    ⍝ Handle the end of a session
      session.APIref.CallAPI'∇CloseAPI∇'   ⍝ internal command to close the API (kill the instance)
      Config.Application.{IPsPorts[1⍳⍨IPsPorts[;⍳2]∧.≡⍵;3]←0}session.(APIServer port)    ⍝ release host & port
    ∇

    ∇ R←GetHostAndPort cfg
      :If cfg.API_Hosts≡,⊂'inSitu'
          R←'inSitu' 0
      :Else
          R←cfg.IPsPorts
          z←R[;3]=0
          :If 0=+/z
              'No more connections available!'⎕SIGNAL 991
          :Else
              R←R[z⍳1;⍳2]
          :EndIf
      :EndIf
    ∇

:endclass
