:Namespace DyalogBuild
⍝ Implement ]build & ]test UCMDs

    ⎕ML←⎕IO←1

    eis←{1=≡⍵:⊂⍵ ⋄ ⍵}                        ⍝ enclose if simple
    split←{{(+/∧\⍵∊' ')↓⍵}¨1↓¨{(⍵=⊃⍵)⊂⍵}⍺,⍵} ⍝ Split ⍵ on ⍺, and remove leading blanks from each segment
    getparam←{⍺←'' ⋄ (⌊/names⍳eis ⍵)⊃values,⊂⍺} ⍝ Get value of parameter
    getnumparam←{⍺←⊣ ⋄⊃2⊃⎕VFI ⍺ getparam ⍵}  ⍝ Get numeric parameter (0 if not set)
    lc←0∘(819⌶) ⋄ uc←1∘(819⌶)                ⍝ lower & upper case
    null←0                                   ⍝ UCMD switch not specified

  ⍝ test "DSL" functions

    ∇ r←QCSV args;z;file;encoding;coltypes;num
    ⍝ Primitive ⎕CSV for pre-v16
    ⍝ No validation, no options
     
      :Trap 2 ⍝ Syntax Error
          r←⎕CSV args
      :Else
          (file encoding coltypes)←args
          z←1⊃⎕NGET file 1
          z←1↓¨↑{(','=⍵)⊂⍵}¨',',¨z
          :If 0≠⍴num←(2=coltypes)/⍳⍴coltypes
              z[;num]←{⊃2⊃⎕VFI ⍵}¨z[;num]
          :EndIf
          r←z
      :EndTrap
    ∇

    ∇ r←expect check got
      :If r←expect≢got
          ⎕←'expect≢got:'
          ⎕←(2⊃⎕SI),'[',(⍕2⊃⎕LC),'] ',(1+2⊃⎕LC)⊃⎕NR 2⊃⎕SI
          ∘∘∘
      :EndIf
    ∇

    ∇ line←line because msg
     ⍝ set global "r", return branch label
      r←(2⊃⎕SI),'[',(⍕2⊃⎕LC),']: ',msg
    ∇

    ∇ r←DoTest args;WIN;start;source;ns;files;f;z;fns;filter;verbose;LOGS;steps;setups;setup;DYALOG;WSFOLDER;suite;crash;m;v;sargs;ignored;type;TESTSOURCE;extension;repeat;run;silent
      ⍝ run some tests from a namespace or a folder
      ⍝ switches: args.(filter setup teardown verbose)
     
      WIN←'W'=⊃⊃'.'⎕WG'APLVersion'
      DYALOG←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
      WSFOLDER←⊃⎕NPARTS ⎕WSID
     
      LOGS←''
      (verbose filter crash silent)←args.(verbose filter crash silent)
      :If null≢repeat←args.repeat
          repeat←⊃2⊃⎕VFI repeat
      :EndIf
      repeat←1⌈repeat
     
      :If 9=#.⎕NC source←1⊃args.Arguments ⍝ It's a namespace
          ns←#⍎source
          TESTSOURCE←⊃1 ⎕NPARTS''
      :Else                               ⍝ Not a namespace
          :If ⎕NEXISTS f←source           ⍝ Argument is a file
          :OrIf ⎕NEXISTS f←source,'.dyalogtest'
              (TESTSOURCE z extension)←⎕NPARTS f
              :If 2=type←⊃1 ⎕NINFO f
                  :If '.dyalogtest'≡lc extension ⍝ That's a suite
                      :If null≡args.suite
                          args.suite←f
                      :EndIf
                      f←¯1↓TESTSOURCE ⋄ type←1 ⍝ Load contents of folder
                  :Else                          ⍝ Arg is a source file - load it
                      ⍝ ns←#.⎕FIX 'file://',f    ⍝ When the interpreter can do it one day
                      ⎕SE.SALT.Load f,' -target=ns'
                      :If verbose ⋄ 0 log'load file ',source ⋄ :EndIf
                  :EndIf
              :EndIf
     
              :If 1=type
                  files←⊃0(⎕NINFO⍠1)f,'/*.dyalog'
                  ns←⎕NS''
                  :For f :In files
                  ⍝ z←ns.⎕FIX 'file://',f ⍝ /// source updates not working
                      ⎕SE.SALT.Load f,' -target=ns'
                  :EndFor
                  :If verbose ⋄ 0 log(⍕≢files),' files loaded from ',source ⋄ :EndIf
              :EndIf
          :Else
              logtest'"',source,'" is neither a namespace or a folder.'
              →fail⊣r←LOGS
          :EndIf
      :EndIf
     
      :If null≢suite←args.suite ⍝ Is a test suite defined?
          ⍝ Merge settings
          ignored←⍬
          sargs←LoadTestSuite suite
     
          :For v :In (sargs.⎕NL-2)∩args.⎕NL-2 ⍝ overlap?
              :If null≢args⍎v
                  ignored,←⊂v
              :EndIf
          :EndFor
          'args'⎕NS sargs ⍝ merge
          :If 0≠≢ignored
              0 log'*** warning - switches overwritten by test suite contents: ',,⍕ignored
          :EndIf
      :EndIf
     
    ⍝ Establish test DSL in the namespace
      :If crash=0 ⋄ ns.check←≢
      :Else
          ns.⎕FX ⎕NR'check'
      :EndIf
      ns.⎕FX ⎕NR'because'
     
      :If 0≠⍴args.tests
          fns←{1↓¨(','=⍵)⊂⍵}args.tests,⍨','~⊃args.tests
          :If ∨/m←3≠⌊ns.⎕NC fns
              0 log'*** function(s) not found: ',,⍕m/fns
              fns←(~m)/fns
          :EndIf
      :Else ⍝ No functions selected - run all named test_*
          fns←↓{⍵⌿⍨'test_'∧.=⍨5(↑⍤1)⍵}ns.⎕NL 3
      :EndIf
     
      setups←{1↓¨(⍵=⊃⍵)⊂⍵}' ',args.setup
      r←LOGS
     
      :For run :In ⍳repeat
          :If verbose∧repeat≠0
              0 log'run #',⍕run
          :EndIf
          :For setup :In setups
              steps←0
              start←⎕AI[3]
              LOGS←''
              :If verbose∧1<≢setups ⋄ r,←⊂'For setup = ',setup ⋄ :EndIf
              :If null≢f←setup
                  :If 3=ns.⎕NC f ⍝ function is there
                      :If verbose ⋄ 0 log'running setup: ',f ⋄ :EndIf
                      f logtest(ns⍎f)⍬
                  :Else ⋄ logtest'-setup function not found: ',f
                  :EndIf
              :EndIf
     
              :For f :In fns
                      steps+←1
                      :If verbose ⋄ 0 log'running: ',f ⋄ :EndIf
                      f logtest(ns⍎f)⍬
              :EndFor
     
              :If null≢f←args.teardown
                  :If 3=ns.⎕NC f ⍝ function is there
                      :If verbose ⋄ 0 log'running teardown: ',f ⋄ :EndIf
                      f logtest(ns⍎f)⍬
                  :Else ⋄ logtest'-teardown function not found: ',f
                  :EndIf
              :EndIf
     
     END:
              :If 0=⍴LOGS ⋄ r,←(silent≡null)/⊂'   ',((1≠≢setups)/setup,': '),(⍕steps),' test',((1≠steps)/'s'),' passed in ',(1⍕0.001×⎕AI[3]-start),'s'
              :Else
                  r,←(⊂'Errors encountered with setup "',setup,'":'),'   '∘,¨LOGS
              :EndIf
          :EndFor ⍝ Setup
      :EndFor ⍝ repeat
     
     fail:
      r←⍪r
    ∇

    ∇ args←LoadTestSuite suite;setups;lines;i;cmd;params;names;values;tmp;f
     
      args←⎕NS''
     
      :If ⎕NEXISTS suite
          lines←⊃⎕NGET suite 1
      :Else
          r←,⊂'Test suite "',suite,'" not found.' ⋄ →0
      :EndIf
     
      :For i :In ⍳≢lines
          (cmd params)←':'split i⊃lines
          :If cmd∧.=' ' ⋄ :Continue ⋄ :EndIf ⍝ Ignore blank lines
          (names values)←↓[1]↑¯2↑¨(⊂⊂''),¨'='split¨','split params
          cmd←lc cmd~' ' ⋄ names←lc names
     
          :If (i=1)∧'dyalogtest'≢cmd
              'First line of file must define DyalogTest version'⎕SIGNAL 11
          :EndIf
     
          :Select cmd
          :Case 'dyalogtest'
              :If 0.1=_version←getnumparam'version' ''
                  :If verbose
                      0 log'DyalogTest version ',⍕_version
                      log'Processing Test Suite "',suite,'"'
                  :EndIf
              :Else
                  'This version of ]test only supports Dyalog Test file format v0.1'⎕SIGNAL 2
              :EndIf
     
          :Case 'setup'
              args.setup←getparam'fn' ''
     
          :Case 'test'
              :If 0=⎕NC'args.tests' ⋄ args.tests←⍬ ⋄ :EndIf
              args.tests,←',',getparam'fn' ''
     
          :Case 'teardown'
              args.teardown←getparam'fn' '' ⍝ function is there
     
          :CaseList 'id' 'description'
              :If verbose ⋄ log cmd,': ',getparam'' ⋄ :EndIf
          :Else
              log'Invalid keyword: ',cmd
          :EndSelect
      :EndFor
    ∇


    ∇ r←DoBuild args;file;prod;path;lines;extn;name;exists;extension;p;i;cmd;params;values;names;_description;_id;_version;id;v;target;source;wild;options;z;tmp;types;varname;start;_defaults;f;files;WIN;n
    ⍝ Process a .dyalogbuild file
     
      WIN←'W'=⊃⊃'.'⎕WG'APLVersion'
      start←⎕AI[3]
      extension←'.dyalogbuild' ⍝ default extension
     
      i←0 ⍝ we are on "line zero" if any logging happens
     
      file←1⊃args.Arguments
      prod←args.production
      DoClear args.clear
     
      (exists file)←OpenFile file
      (path name extn)←⎕NPARTS file
     
      ('File not found: ',file)⎕SIGNAL exists↓22
     
      lines←1⊃⎕NGET file 1
     
      _version←0
      _id←''
      _description←''
      _defaults←'⎕ML←⎕IO←1'
     
      :For i :In ⍳≢lines
          (cmd params)←':'split i⊃lines
          :If cmd∧.=' ' ⋄ :Continue ⋄ :EndIf ⍝ Ignore blank lines
          (names values)←↓[1]↑¯2↑¨(⊂⊂''),¨'='split¨','split params
          cmd←lc cmd~' ' ⋄ names←lc names
     
          :If (i=1)∧'dyalogbuild'≢cmd
              'First line of file must define DyalogBuild version'⎕SIGNAL 11
          :EndIf
     
          :Select cmd
          :Case 'dyalogbuild'
              :If 0.1=_version←getnumparam'version' ''
                  0 log'DyalogBuild version ',⍕_version
                  log'Processing "',file,'"'
              :Else
                  'This version of ]build only supports Dyalog Build file format v0.1'⎕SIGNAL 2
              :EndIf
     
          :Case 'id'
              id←getparam'id' ''
              v←getnumparam'version'
              log'Building ',id,(v≠0)/' version ',⍕v
     
          :Case 'description'
              ⍝ no action
     
          :Case 'copy'
              wild←'*'∊source←getparam'file' ''
              target←getparam'target'
     
              :If ⎕NEXISTS path,target
                  :For f :In files←⊃0(⎕NINFO⍠1)path,target,'/*'
                      ⎕NDELETE f
                  :EndFor
              :Else
                  2 ⎕MKDIR path,target ⍝ /// needs error trapping
              :EndIf
     
              :If 0=≢files←⊃0(⎕NINFO⍠1)path,source
                  logerror'No files found to copy in ":',path,source,'"'
              :Else
                  :For f :In files
                      cmd←((1+WIN)⊃'cp' 'copy'),' "',f,'" "',path,target,'/"'
                      ((WIN∧cmd∊'/')/cmd)←'\'
                      {}⎕CMD cmd
                  :EndFor
              :EndIf
              :If (n←≢files)≠tmp←≢⊃0(⎕NINFO⍠1)path,target,'/*'
                  logerror(⍕n),' expected, but ',(⍕tmp),' files ended up in "',target,'"'
              :Else
                  log(⍕n),' file',((n≠1)/'s'),' copied from "',source,'" to "',target,'"'
              :EndIf
     
          :Case 'run'
              logerror'run is under development'
              :Continue
     
              tmp←getparam'file' ''
              (exists tmp)←OpenFile tmp
              :If ~exists ⋄ logerror'unable to find file ',tmp ⋄ :Continue ⋄ :EndIf
     
          :CaseList 'ns' 'class' 'csv'
              target←'#'getparam'target'
              target←(('#'≠⊃target)/'#.'),target
              :If 0=≢source←getparam'source' ''
                  'Source is required'signal 11
              :EndIf
     
              :If (cmd≡'ns')∧0=⎕NC target
                  target ⎕NS''
                  :Trap 0
                      target⍎_defaults
                       ⍝ log'Created namespace ',target
                  :Else
                      logerror'Error establishing defaults in namespace ',target,': ',⊃⎕DMX.DM
                  :EndTrap
              :EndIf
     
              :If cmd≡'csv'
                  types←2⊃⎕VFI getparam'coltypes'
                  :If ~0=tmp←#.⎕NC target
                      logerror'Not a free variable name: ',target,', current name class = ',⍕tmp ⋄ :Continue
                  :EndIf
                  :Trap 999
                      tmp←QCSV(path,source)'',(0≠≢types)/⊂types
                      ⍎target,'←tmp'
                      log target,' defined from CSV file "',source,'"'
                  :Else
                      logerror⊃⎕DMX.DM
                  :EndTrap
                  :Continue
              :EndIf
     
              wild←'*'∊source
              options←(wild/' -protect'),prod/' -nolink'
     
              :Trap 0
                  z←⎕SE.SALT.Load tmp←path,source,((0≠≢target)/' -target=',target),options
              :Else
                  logerror⊃⎕DMX.DM
                  :Continue
              :EndTrap
     
              :If 0=≢z     ⍝ no names
                  logerror'Nothing found: ',tmp
              :ElseIf 1=≢z ⍝ exactly one name
                  log{(uc 1↑⍵),1↓⍵}cmd,' ',source,' loaded as ',⍕z
              :Else        ⍝ many names
                  log(⍕≢z),' names loaded from ',source,' into ',target
              :EndIf
     
          :CaseList 'lx' 'exec' 'defaults'
              :If 0=≢tmp←getparam'expression' ''
                  logerror'expression missing'
              :Else
                  :If cmd≡'lx'
                      #.⎕LX←tmp
                      log'Latent Expression set'
                  :Else ⍝ exec or defaults
                      :Trap 0 ⋄ #⍎tmp
                      :Else
                          logerror⊃⎕DMX.DM
                      :EndTrap
                      :If cmd≡'defaults' ⋄ _defaults←tmp ⋄ :EndIf ⍝ Store for use each time a NS is created
                  :EndIf
              :EndIf
     
          :Case 'target'
              :If 0=≢tmp←getparam'wsid' ''
                  logerror'wsid missing'
              :Else
                  ⎕WSID←∊1 ⎕NPARTS path,tmp
                  log'WSID set to ',⎕WSID
              :EndIf
     
          :Else
              logerror'Invalid keyword: ',cmd
          :EndSelect
     
      :EndFor
      :If prod ⋄ ⎕EX'#.SALT_Var_Data' ⋄ :EndIf
      r←'DyalogBuild: ',(⍕≢lines),' lines processed in ',(1⍕0.001×⎕AI[3]-start),' seconds.'
    ∇

    ∇ (exists file)←OpenFile file;tmp;path;extn;name
      (path name extn)←⎕NPARTS file
      :If exists←⎕NEXISTS file
          :If 1=⊃1 ⎕NINFO file ⍝ but it is a folder!
          :AndIf ⎕NEXISTS tmp←file,'/',name,extension ⍝ If folder contains name.dyalogbuild
              file←tmp ⍝ Then use the file instead
          :EndIf
      :Else
          exists←⎕NEXISTS file←file,(0=⍴extn)/extension
      :EndIf
    ∇

    ∇ DoClear clear;tmp;n
      →(clear≡0)⍴0
      :If (clear≡1)∨0=≢clear ⋄ #.(⎕EX ⎕NL⍳9) ⋄ log'workspace cleared'
      :ElseIf ∧/1⊃tmp←⎕VFI clear
          n←#.⎕NL 2⊃tmp
          #.⎕EX n ⋄ log'Expunged ',(⍕≢n),' names of class ',clear
      :Else
          logerror'invalid argument to clear, should be empty or a numeric list of name classes to expunge'
      :EndIf
    ∇

    lineno←{'[',(,'ZI3'⎕FMT ⍵),']'}

    ∇ {f}logtest msg
      →(0=⍴msg)⍴0
      :If 2=⎕NC'f' ⋄ msg←f,': ',msg ⋄ :EndIf
      :If verbose ⋄ ⎕←msg ⋄ :EndIf
      LOGS,←⊂msg
    ∇

    ∇ {pre}log msg
      :If 0=⎕NC'pre' ⋄ :OrIf pre=1 ⋄ msg←' ',(lineno i),' ',msg ⋄ :EndIf
      ⎕←msg
    ∇

    ∇ dm signal en
     ⍝ subroutine of DoBuild: uses globals i and file
      (dm,' in line ',(lineno i),' of file ',file)⎕SIGNAL 2
    ∇

    ∇ logerror msg
     ⍝ subroutine of DoBuild: uses globals i and file
      ⎕←' ***** ',(lineno i),' ',msg
    ∇

    ∇ r←List
      r←⎕NS¨2⍴⊂''
      r.(Group Parse)←⊂'SALT' '' ⍝ Defaults
     
      r.Name←'Build' 'Test'
      r[1].Desc←'Execute a DyalogBuild file'
      r[1].Parse←'1S -production -clear[=]'
      r[2].Desc←'Run tests from a namespace or folder'
      r[2].Parse←'1S -filter= -setup= -teardown= -suite= -verbose -silent -crash -repeat='
    ∇

    ∇ Û←Run(Ûcmd Ûargs);file
     ⍝ Run a build
     
      :Select Ûcmd
      :Case 'Build'
          Û←DoBuild Ûargs
      :Case 'Test'
          Û←DoTest Ûargs
      :Else
          Û←'Unable to run command ',Ûcmd
          Û←0 0⍴''
      :EndSelect
    ∇

    ∇ r←level Help Cmd
      (1↑Cmd)←⎕SE.Dyalog.Utils.ucase 1↑Cmd
      :If 'Build'≡Cmd
          r←⊂'Runs one or more DyalogBuild scripts'
          :If 0=level
              r,←⊂'Args: filenames [-production]]'
          :Else
              r,←'' 'Argument is name of a .dyalogbuild file'
              r,←'' '-production will remove links to source files' '-clear[=ncs] will expunge all objects, or objects of specified nameclasses'
          :EndIf
      :ElseIf 'Test'≡Cmd
          r←⊂'Run a selection of functions named test_* from a namespace or folder'
          :If 0=level
              r,←⊂'Args: ns-or-folder [-filter=string] [-setup=fn] [-teardown=fn]]'
          :Else
              r,←'' 'Argument is the name of a namespace in the current workspace, or'
              r,←'         the name of a .dyalog file containing a namespace, or'
              r,←'         the name of a folder containing functions in .dyalog format'
              r,←'' '-suite=filename  will run tests defined by a .dyalogtest file'
              r,←⊂'-filter=string   will only run functions where string is found in the leading ⍝Test: comment'
              r,←⊂'-setup=fnname    will run fnname before any tests'
              r,←⊂'-teardown=fnname will run fnname after all tests'
              r,←⊂'-crash           to crash on error, rather than log and continue'
              r,←⊂'-repeat=n        repeat test n times'
              r,←⊂'-verbose         chatty mode while running'
              r,←⊂'-silent          qa mode: only output actual errors'
          :EndIf
      :Else
          r←'Internal error: no help available for ',Cmd
      :EndIf
    ∇

:Endnamespace ⍝ DyalogBuild
