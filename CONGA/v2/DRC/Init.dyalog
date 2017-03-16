 r←{reset}Init path;dllname;z;Path;ZSetHeader;unicode;bit64;filename;Paths;win;s;dirsep;mac;rootarg
     ⍝ Initialize Conga v3.0.0

 :If 2=⎕NC'reset' ⋄ :AndIf 2=⎕NC'⍙naedfns' ⋄ :AndIf reset=¯1    ⍝ Reload the dll
     {}Close'.'
 :EndIf

 :If 3=⎕NC'⍙InitRPC' ⍝ Library already loaded
     r←0 'Conga already loaded'
     :If 2=⎕NC'reset' ⋄ :AndIf reset=1
         {}Close¨Names'.'
         r←0 'Conga reset'
     :EndIf

 :Else ⍝ Not loaded
     {}⎕WA  ⍝ If there is garbage holding the shared library loaded get rid of it
     unicode←⊃80=⎕DR' '
     mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂1⊃'.'⎕WG'APLVersion'
     ⍝ Dllname is Conga[x64 if 64-bit][Uni if Unicode][.so if UNIX]
     filename←'conga30',(⊃'__CU'[⎕IO+unicode]),(⊃('32' '64')[⎕IO+bit64]),⊃('' '.so' '.dylib')[⎕IO+mac+~win]
     dirsep←'/\'[⎕IO+win]
     :If win
             ⍝ if path is empty windows finds the .dll next to the .exe
         Path←DefPath path
     :Else
          ⍝ if unix/linux rely on the setting of LIBPATH/LD_LIBRARY_PATH
         Path←''
     :EndIf
     s←''

     :Trap 0
         ⍙naedfns←⍬
         dllname←'I4 "',Path,filename,'"|'
         :If win∧0<⍴Path
             :Trap 0
                 {}'cheat'⎕NA'I4 "',Path,(7↑filename),'ssl',((⎕IO+bit64)⊃'32' '64'),'"|congasslversion >0T1 I4'
             :EndTrap
         :EndIf
         :Trap 0
             ⍙naedfns,←⊂'⍙Version'⎕NA dllname,'Version'
         :Else
             ⎕FX'r←⍙Version' 'r←20700000'
         :EndTrap

         ⍙naedfns,←⊂'⍙CallR'⎕NA dllname,'Call& <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
         :If 0<⎕NC'cheat'
             {}⎕EX'cheat'
         :EndIf
         ⍙naedfns,←⊂'⍙CallRL'⎕NA dllname,'Call& <0T1 <0T1 =Z <Z'  ⍝ Left input
         ⍙naedfns,←⊂'⍙CallRnt'⎕NA dllname,'Call <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
         ⍙naedfns,←⊂'⍙CallRLR'⎕NA dllname,'Call1& <0T1 <0T1 =Z >Z' ⍝ Left output
         ⍙naedfns,←⊂'KickStart'⎕NA dllname,'KickStart& <0T1'
         ⍙naedfns,←⊂'SetXlate'⎕NA dllname,'SetXLate <0T <0T <C[256] <C[256]'
         ⍙naedfns,←⊂'GetXlate'⎕NA dllname,'GetXLate <0T <0T >C[256] >C[256]'
         :Trap 0
             ⍙naedfns,←⊂⎕NA'F8',2↓dllname,'Micros'
             ⍙naedfns,←⊂⎕NA dllname,'cflate  I4  =P  <U1[] =U4 >U1[] =U4 I4'
         :EndTrap
         :Trap 0
             z←InitRawIWA dllname
         :EndTrap
         ⍙naedfns,←⊂'⍙InitRPC'⎕NA dllname,'Init <0T1 <0T1'

         z←⍙InitRPC RootName Path
         :If 1091=⊃z
             :If ~unicode
                 s←SetXlate DefaultXlate
             :EndIf
             s←' using default translation aplunicd.ini not present'
             r←,0
         :Else
             r←Error z
         :EndIf

     :EndTrap


     :If 3=⎕NC'⍙InitRPC'

         :If 0=⊃r
             r←0('Conga loaded from: ',Path,filename,s)
             X509Cert.LDRC←⎕THIS            ⍝ Set LDRC so X509Cert can find DRC
             flate.LDRC←⎕THIS
         :Else
             z←⎕EX¨⍙naedfns
         :EndIf
     :Else
         r←1000('Unable to find DLL "',filename,'"')('Tried: ',,⍕Path)
     :EndIf
 :EndIf
