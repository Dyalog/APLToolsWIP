:Namespace DRC
⍝ $Revision: 1161 $ $Date: 2016-12-14 09:58:51 +0100 (Wed, 14 Dec 2016) $
  ⍝ test
    RootName←'DRC'
    ErrorTable←94 3⍴  0 'SUCCESS' '' 100 'TIMEOUT' '' 1000 'ERR_LOAD_DLL' '' 1001 'ERR_LENGTH' '' 1002 'ERR_RANK' '' 1003 'ERR_VALUE' '' 1004 'ERR_DOMAIN' '' 1005 'ERR_NONCE' '' 1006 'ERR_ROOT_NOT_FOUND' '' 1007 'ERR_PARENT_NOT_FOUND' '' 1008 'ERR_INVALID_OBJECT' '' 1009 'ERR_NAME_IN_USE' '' 1010 'ERR_OBJECT_NOT_FOUND' '' 1011 'ERR_ROOT_EXISTS' '' 1012 'ERR_MEMORY_ALLOC' '' 1013 'ERR_UNKNOWN_CLASS' '' 1014 'ERR_UNKNOWN_ACTION' '' 1015 'ERR_UNSUPPORTED' '' 1016 'ERR_OPEN_BIND' '' 1017 'ERR_OPEN_SINGLE' '' 1018 'ERR_OPEN_DOUBLE' '' 1019 'ERR_VAR_DEF' '' 1020 'ERR_USE_DEFAULT' '' 1021 'ERR_INVALID_IDENTIFIER' '' 1022 'ERR_INVALID_MODIFIER' '' 1023 'ERR_INVALID_NAME' '' 1024 'ERR_INVALID_BROTHER' '' 1025 'ERR_UNKNOWN_SERVICE' '' 1026 'ERR_CLOSE_BUFFER' '' 1027 'ERR_COLUMN_WIDTH' '' 1028 'ERR_OPEN_PARA' '' 1029 'ERR_UNKNOWN_NET' '' 1030 'ERR_COLUMN' '' 1031 'ERR_MAX_CURSORS' '' 1032 'ERR_APL_TO_BUFFER' '' 1033 'ERR_PROFF' '' 1034 'ERR_BIND_TO_LARGE' '' 1035 'ERR_UNKNOWN_TYPE' '' 1036 'ERR_CONVERSION' '' 1037 'ERR_OPTION' '' 1038 'ERR_INDEX' '' 1039 'ERR_FILE' '' 1040 'ERR_PARENT' '' 1041 'ERR_OBJTYPE' '' 1042 'ERR_SIZE' '' 1043 'ERR_ALLREADY_INITIALIZED' '' 1044 'ERR_NOT_INITIALIZED' '' 1045 'ERR_ARG_INVALID' '' 1046 'ERR_ARG_MISSING' '' 1047 'ERR_ARG_STOPLIST' '' 1048 'ERR_DECF' '' 1100 'ERR_NEW_CMD_SOCKET' '/* Create New Command socket */' 1101 'ERR_NEW_DATA_SOCKET' '/* Create New Data socket */' 1102 'ERR_LISTEN' '/* Could not make socket listen */' 1103 'ERR_STATE' '/* Object have invalid state for this action */' 1104 'ERR_SEND' '/* Could not send data*/' 1105 'ERR_RECV' '/* Could not receive data */' 1106 'ERR_INVALID_HOST' '/* Host identification not resolved */' 1107 'ERR_INVALID_SERVICE' '/* Service identification not resolved */' 1108 'ERR_TIMEOUT' '/* Request timed out */' 1109 'ERR_SEND_CREQ' '/* Could not send CREQ to host */' 1110 'ERR_CONNECT_CMD' '/* Could not connect to host cmd port */' 1111 'ERR_CONNECT_DATA' '/* Could not connect to host data port */' 1112 'ERR_CONNECT_NACK' '/* Host refused connection */' 1113 'ERR_RECV_CMDANSWER' '/* Could not receive CMD answer from host */' 1114 'ERR_RECV_CREQ' '/* Could not receive CREQ */' 1115 'ERR_NOT_CREQ' '/* Received packet not a CREQ */' 1116 'ERR_SOCK_PORT' '/* Could not retrive socket port */' 1117 'ERR_SEND_PORT' '/* Could not send port packet to client */' 1118 'ERR_SEND_NACK' '/* Could not send nack packet to client */' 1119 'ERR_CLOSED' '/* Socket Closed while receiving */' 1120 'ERR_ACCEPT' '/* Could not accept socket  */' 1121 'ERR_THREAD_NOT_FOUND' '/* Thread not found */' 1122 'ERR_WAIT_SEM' '/* Wait did not return WAIT_OBJECT_0 or WAIT_TIMEOUT*/' 1123 'ERR_SOMEBODY_WAITING' '/* Another thread is allready waiting*/' 1124 'ERR_WORKSYNC_RECV' '' 1125 'ERR_NEW' '' 1126 'ERR_UNKNOWN_ANSWER' '/* Received an asnwer that cannot be matched with command.*/' 1127 'ERR_OBJECT_ACTIVITY' '/* Cannot delete object because of TCP/IP activity */' 1128 'ERR_NEW_THREAD' '/* Error creating new thread */' 1129 'ERR_NEW_SEMAPHORE' '/* Error creating new semaphore */' 1130 'ERR_WRONG_MAGIC' '/* Package with wrong magic received */' 1131 'ERR_ARCHITECTURE' '/* The architecture of the Z passed is not recognized */' 1132 'ERR_INVALID_ADDR' '/* We are unable to get information on the socket */' 1133 'ERR_FORK' '/* Conga have been forked and the workthread in the copy have ended */'  1201 'ERR_TLSHANDSHAKE' '/* unable to complete a TLS handshake with the peer */'  1202 'ERR_INVALID_PEER_CERTIFICATE' '/* The peers certificate is not valid */'  1203 'ERR_COULD_NOT_LOAD_CERTIFICATE_FILES' '/* Either the specified certificate file or private key file is not valid or could not be found. */'  1204 'ERR_INITIALISING_TLS' '/* There was an error initialising GnuTLS. */' 1205 'ERR_NO_SSL_SUPPORT' '/* There is no SSL support in this build of the conga DLL */'   1206 'ERR_HANDSHAKE_NOT_COMPLETED'    '/* GNU TLS HandShake did not complete  */' 1207 'ERR_INVALID_CERTIFICATE' '/* Cannot decode certificate */' 1300 'ERR_CERT_COUNT_FAILED' '/* Failed to count systems stores */'  1301 'ERR_CERT_NOT_FOUND' '/* Failed to find cert in certificate stores */'
    ErrorTable⍪←2 3⍴ 1134 'ERR_CALL_FAILED' '/* Operating System Call failed*/' 1135 'ERR_MAX_BLOCK_SIZE' '/* Max block size exeeded */'
    
    ∇ r←bit2problem a      ⍝ returned by DRC.Clt in case secure connection fails with error 1202
      r←a{(((⍴⍵)/2)⊤⍺)/⍵}'' 'CERT_INVALID' '' '' 'REVOKED' 'SIGNER_NOT_FOUND' 'SIGNER_NOT_CA' 'INSECURE_ALGORITHM' 'NOT_ACTIVATED' 'CERT_EXPIRED' 'SIGNATURE_FAILURE' 'REVOCATION_DATA_SUPERSEDED' '' 'UNEXPECTED_OWNER' 'REVOCATION_DATA_ISSUED_IN_FUTURE' 'SIGNER_CONSTRAINTS_FAILURE' 'MISMATCH'
     
    ∇


      check←{
          0≠⊃⍵:('DLL Error: ',,⍕⍵)⎕SIGNAL 999
          0≠⊃2⊃⍵:(Error⊃2⊃⍵),1↓2⊃⍵
          2=⍴⍵:(⎕IO+1)⊃⍵
          1↓⍵}

    asAv←{⎕av[(⎕nxlate 0)⍳¯1+⎕av⍳⍵]    }

      lcase←{                                         ⍝ Lower-casification,
          lc←'abcdefghijklmnopqrstuvwxyzåäöàæéñøü'    ⍝ (lower case alphabet)
          uc←'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖÀÆÉÑØÜ'    ⍝ (upper case alphabet)
          (lc,⎕AV)[(uc,⎕AV)⍳⍵]                        ⍝ ... of simple array.
      }

    ncase ←{(1<≡⍺)∧1<≡⍵: (lcase ¨⍺) ⍺⍺ (lcase¨ ⍵) ⋄ (lcase ⍺) ⍺⍺ lcase ⍵ }
    
    Magic←{(4/256)⊥⎕UCS 4↑⍵}   
    NetSize←{,(4/256)⊤⍵}
    Wrap←{(NetSize 8+⍴⍵),⎕UCS'HEAD',⍵}
    
    ∇ p←DefPath p;ds;trunkds;addds;isWin;subst
      subst←{((1⊃⍺),⍵)[1+(⍳⍴⍵)×⍵≠2⊃⍺]}
      isWin←{'Window'{⍺≡(⍴⍺)↑⍵}⎕IO⊃'.'⎕WG'aplversion'}
      ds←'/\'[⎕IO+isWin ⍬]
      trunkds←{⍺←ds ⋄ (1-(⌽⍵)⍳⍺)↓⍵}
      addds←{⍺←ds ⋄ ⍵,(⍺≠¯1↑⍵)/⍺}
     
      :Select p
      :Case '⍵' ⍝ means path of the ws
          p←trunkds ⎕WSID
      :Case '↓' ⍝ means current path
          :If isWin ⍬
              p←addds⊃⎕CMD'cd'
          :Else
              p←addds⊃⎕CMD'pwd'
          :EndIf
      :Case '⍺' ⍝ means the path of the interpreter
          p←trunkds ⎕IO⊃+2 ⎕NQ'.' 'GetCommandlineArgs'
      :Case ''
          p←p
      :Else
          p←addds((isWin ⍬)⌽'/\')subst p
      :EndSelect
     
    ∇

    ∇ r←arg getargix(args list);mn;mp;ixs;nix
      ⍝ Finds argumenst in a list of positional and named arguments
     
      ixs←list⍳ncase args
     
      nix←+/∧\2>|≡¨arg ⍝ identify where the named arguments starts
     
      r←(⍴ixs)⍴1+⍴list      ⍝ prefill the result
      mp←ixs≤nix
      :If ∨/mp        ⍝ for positionals args
          (mp/r)←mp/ixs
      :EndIf
      mn←(~mp)∧ixs<1+⍴list
      :If ∨/mn       ⍝ for named args.
      :AndIf nix<⍴arg
          (mn/r)←-nix+(1⊃¨nix↓arg)⍳ncase mn/args
     
      :EndIf
    ∇

    ∇ r←a getarg ixs;m
      m←0<ixs
      r←(⍴ixs)⍴⍬
      :If ∨/m
          (m/r)←a[m/ixs]
      :EndIf
      m←~m
      :If ∨/m
          (m/r)←2⊃¨a[-m/ixs]
      :EndIf
    ∇

    ∇ r←reparg a;arglist;ix;cert
      arglist←'Name' 'Address' 'Port' 'Mode' 'BufferSize' 'SSLValidation' 'EOM' 'IgnoreCase' 'Protocol' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData' 'X509'
      ix←a getargix('X509' 'PublicCertData' 'PrivateKeyFile' 'PrivateKeyPass' 'PublicCertFile' 'PublicCertPass' 'PrivateKeyData')(arglist)
      :If (⍴a)≥|⊃ix
          cert←a getarg⊃ix
     
          :If 9=⎕NC'cert'
          ⍝:AndIf 0<cert.IsCert   ⍝Accept empty certificates.
              a←(~(⍳⍴a)∊|ix)/a
              a,←cert.AsArg
          :EndIf
      :EndIf
      r←a
    ∇



    ∇ r←Close con;_
     ⍝ arg:  Connection id
      r←check ⍙CallR RootName'AClose'con 0
      :If ((,'.')≡,con)∧(0<⎕NC'⍙naedfns')  ⍝ Close root and unload share lib
          _←⎕EX¨⍙naedfns
          _←⎕EX'⍙naedfns'
      :EndIf
    ∇

    ∇ v←Version;version
     
      :Trap 0
          version←{no←(¯1+(⍵∊⎕D)⍳1)↓⍵ ⋄ 3↑⊃¨2⊃¨⎕VFI¨'.'{1↓¨(⍺=⍵)⊂⍵}'.',no}
          v←version 2 1 4⊃Tree'.'
      :Else
          'Try DRC.Init '⎕SIGNAL 16
          v←0 0 0
      :EndTrap
    ∇

    ∇ r←Describe name;enum;state;type
      ⍝ Return description of object
     
      :If 0=1↑r←Tree name
          r←2 1⊃r
          enum←{2↓¨(⍵=1↑⍵)⊂⍵}
          state←enum',SNew,SIncoming,SRootInit,SListen,SConnected,SAPL,SReadyToSend,SSending,SProcessing,SReadyToRecv,SReceiving,SFinished,SMarkedForDeletion,SError,SDoNotChange,SShutdown,SSocketClosed,SAPLLast,SSSL,SSent,SListenPaused'
          type←enum',TRoot,TServer,TClient,TConnection,TCommand,TMessage'
     
          :If 0=2⊃r ⍝ Root
              r←0('[DRC]'(4⊃r)('State=',(1+3⊃r)⊃state)('Threads=',⍕5⊃r))
          :Else     ⍝ Something else
              (2⊃r)←(1+2⊃r)⊃type
              (3⊃r)←(1+3⊃r)⊃state
              r←0 r
          :EndIf
      :EndIf
    ∇

    ∇ r←Error no;i
      ⍝ Return error text
     
      :If (1↑⍴ErrorTable)≥i←ErrorTable[;1]⍳no
          r←ErrorTable[i;]
      :ElseIf (no<1000)∨no>10000
          r←no('OS Error #',⍕no)'Consult TCP documentation'
      :Else
          r←no'? Unknown Error' ''
      :EndIf
    ∇

    ∇ r←Exists root
     ⍝ 1 if a Conga object name is in use
      r←0≡⊃⊃Tree root
    ∇

    ∇ r←GetProp a
      ⍝ Name Prop
      ⍝ Root: DefaultProtocol  PropList  ReadyStrategy  RootCertDir
      ⍝ Server: OwnCert  LocalAddr  PropList
      ⍝ Connection: OwnCert  PeerCert  LocalAddr  PeerAddr  PropList
     
      r←check ⍙CallR RootName'AGetProp'a 0
     
      :If 0=⊃r
      :AndIf ∨/'OwnCert' 'PeerCert'∊a[2]
      :AndIf 0<⊃⍴2⊃r
          (2⊃r)←SetParents ⎕NEW¨X509Cert,∘⊂¨2⊃r
      :EndIf
    ∇

    ∇ r←Certs a
      ⍝ Working with certificates.
      ⍝ ListMSStores
      ⍝ MSStore storename Issuer subject details api password
      ⍝ Folder not implemented
      ⍝ DER  not implemented
      ⍝ PK#12 not implemented
      r←check ⍙CallR RootName'ACerts'a 0
    ∇

    ∇ r←InitRawIWA dllname
      ⍙naedfns,←⊂'IWAStart'⎕NA dllname,'IFAuthClientStart >P <0T1 <0T1'
      ⍙naedfns,←⊂'IWAGet'⎕NA dllname,'IFAuthGetToken P >U4 =U4 >C1[]'
      ⍙naedfns,←⊂'IWASet'⎕NA dllname,'IFAuthSetToken P U4  <C1[]'
      ⍙naedfns,←⊂'IWAFree'⎕NA dllname,'IFAuthFree P '
      ⍙naedfns,←⊂'IWAName'⎕NA dllname,'IFAuthName P >0T1'
      r←0
    ∇

    ∇ r←{reset}Init path;dllname;z;Path;ZSetHeader;unicode;bit64;filename;Paths;win;s;dirsep;mac;rootarg
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
    ∇

    ∇ r←Names root
     ⍝ Return list of top level names
     
      :If 0=1↑r←Tree root
          r←{0=⍴⍵:⍬ ⋄ (⊂1 1)⊃¨⍵}2 2⊃r
      :EndIf
    ∇

    ∇ r←Progress a;cmd;data;⎕IO
     ⍝ cmd data
      ⎕IO←1 ⋄ r←check ⍙CallRL RootName'ARespondZ'(a[1],0)(2⊃a)
    ∇

    ∇ r←Respond a;⎕IO
     ⍝  cmd  data
      ⎕IO←1 ⋄ r←check ⍙CallRL RootName'ARespondZ'(a[1],1)(2⊃a)
    ∇


    ∇ r←SetProp a
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ⍙CallR RootName'ASetProp'a 0
    ∇

    ∇ r←SetRelay a
      ⍝ Name Prop Value
      ⍝ 'RelayFrom' 'RelayTo' [blocksize=16384 [oneway=0]]
     
      r←check ⍙CallR RootName'ASetRelay'a 0
    ∇

    ∇ r←SetPropnt a
      ⍝ Name Prop Value
      ⍝ '.' 'CertRootDir' 'c:\certfiles\ca'
     
      r←check ⍙CallRnt RootName'ASetProp'a 0
    ∇

    ∇ r←Tree a
      ⍝ Name
      r←check ⍙CallR RootName'ATree'a 0
    ∇

    ∇ r←isWindows;n;s
      n←⍴s←'Windows'
      r←s≡n↑⎕IO⊃'.'⎕WG'aplversion'
    ∇
    ∇ pid←WinPid;gcp
      _←'gcp'⎕NA'I kernel32|GetCurrentProcessId'
      pid←gcp
    ∇
    ∇ pid←NixPid
      pid←2⊃⎕VFI ⎕SH'echo $PPID'
    ∇

      GetPid←{
          isWindows:WinPid
          NixPid
      }
    
    ∇ Stat arg;m;NewTS;⎕IO;fopen;loginfo
      :Trap 0
          fopen←{                              ⍝ handle on null file.
              0::⎕SIGNAL ⎕EN                  ⍝ signal error to caller.
              22::⍵ ⎕FCREATE 0                ⍝ ~exists: create.
              ⍵ ⎕FSTIE 0                      ⍝  exists: tie.
          }
          loginfo←{_←(⍙PID ⍙Stat ⎕TS(Micros)(⍙Cnts)(Tree'.'))⎕FAPPEND tie←fopen ⍵ ⋄ ⎕FUNTIE tie}
          ⎕IO←1
          NewTS←⌊Micros÷300000000
      ⍝NewTS←5↑⎕TS
          :If ∨/0=⎕NC'⍙LastTS' '⍙Cnts' '⍙MaxCnts' '⍙Items'
              ⍙Items←'Error' 'Receive' 'Progress' 'Connect' 'Block' 'BlockLast' 'Sent'
              ⍙LastTS←NewTS
              ⍙MaxCnts←⍙Cnts←(2+⍴⍙Items)⍴0
              ⍙PID←GetPid ⍬
              :If 0=⎕NC'⍙Stat'
                  ⍙Stat←1
              :EndIf
          :EndIf
          :If ⍙LastTS≡NewTS
              ⍙Cnts[⍙Items⍳(4↑arg)[2]]+←1
              ⍙Cnts[2+⍴⍙Items]+←{⎕SIZE'⍵'}(4↑arg)[4]
          :Else
              loginfo'congastat.dcf'
              ⍙MaxCnts⌈←⍙Cnts
              ⍙LastTS←NewTS
              ⍙Cnts←(2+⍴⍙Items)⍴0
     
     ⍝ Save
          :EndIf
      :EndTrap
    ∇

    ∇ r←Wait a;⎕IO
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2]
      :If 0<⎕NC'⍙Stat' ⋄ Stat r ⋄ :EndIf
     
    ∇

    ∇ r←Waitt a;⎕IO
     ⍝ Name [timeout]
     ⍝ returns: err Obj Evt Data
      ⎕IO←1
      :If (1≥≡a)∧∨/80 82∊⎕DR a
          a←(a)1000
      :EndIf
      →(0≠⊃⊃r←check ⍙CallRLR RootName'AWaitZ'a 0)⍴0
      ⍝:If 0=⊃⊃r ⋄ timing,←⊂(4⊃4↑⊃r),Micros ⋄ :EndIf
      r←(3↑⊃r),r[2],⊂(4⊃4↑⊃r),Micros
    ∇



    ∇ r←DefaultXlate;⎕IO;x1;x2
    ⍝ Retrieve Default translate tables for Dyalog APL
     
      ⎕IO←0
      x1←⎕NXLATE 0
      x2←x1⍳⍳⍴x1
     
      r←'DYA_IN' 'ASCII'(⎕AV[x1])(⎕AV[x2])
    ∇

    ∇ r←Srv a;ix;arglist;cert
⍝ Create a Server
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'
     
      a←reparg a
      r←check ⍙CallR RootName'ASrv'a 0
    ∇
    ∇ r←Clt a
⍝ Create a Client
⍝    "Name",            // string
⍝    "Address",         // string
⍝    "Port",            // Integer or service name
⍝    "Mode",            // command,raw,text
⍝    "BufferSize",
⍝    "SSLValidation",   // integer
⍝    "EOM",             // Vector of stop strings
⍝    "IgnoreCase",      // boolean
⍝    "Protocol",        // ipv4,ipv6
⍝    "PublicCertData",
⍝    "PrivateKeyFile",
⍝    "PrivateKeyPass",
⍝    "PublicCertFile",
⍝    "PublicCertPass",
⍝    "PrivateKeyData'
     
      a←reparg a
      r←check ⍙CallR RootName'AClt'a 0
    ∇

    ∇ r←Send a;⎕IO
     ⍝ Name data {CloseConnection}
      ⎕IO←1
      r←check ⍙CallRL RootName'ASendZ'((a,0)[1 3])(2⊃a)
    ∇

    ∇ vc←SetParents vc;ix;m
      ix←vc.Elements.Subject⍳vc.Elements.Issuer  ⍝ find the index of the parents
      m←(ix≤⍴vc)∧ix≠⍳⍴ix                         ⍝ Mask the found items with parents and not selfsigned
      (m/vc).ParentCert←vc[m/ix]                 ⍝ Set the parent
      vc←vc~vc.ParentCert                        ⍝ remove all parents from list
    ∇

    ∇ r←ServerAuth con;tok;rr;kp;err;rc;ct;ck;ce
      err←SetProp con'IWA'('NTLM' '')
      :Repeat
          rr←Wait con 1000
          :If 0=⊃rr
              (ce ck ct)←3↑4⊃rr
              :If 0<⍴ct
              :AndIf ce=0
                  err←SetProp con'Token'(ct)
                  kp tok←2⊃GetProp con'Token'
                  rc←Respond(2⊃rr)(err kp tok)
              :Else
                  rc←Respond(2⊃rr)(0 0 ⍬)
                  kp←0
              :EndIf
          :Else
              kp←1
          :EndIf
      :Until (0=kp)∨(ck=0)
      r←GetProp con'IWA'
    ∇

    ∇ r←ClientAuth arg;con;tok;cmd;rc;rr;kp;err;se;sk;st
      :If 1=≡arg
          arg←,⊂arg
      :EndIf
      con←1⊃arg
      err←SetProp con'IWA'('NTLM' '',1↓arg)
      :Repeat
          kp tok←2⊃GetProp con'Token'
          rc cmd←Send con(err kp tok)
          rr←Wait cmd 10000
          :If 0=⊃rr
              (se sk st)←3↑4⊃rr
     
              :If 0<⍴st
              :AndIf se=0
                  err←SetProp con'Token'(st)
              :Else
                  kp←0
              :EndIf
          :EndIf
      :Until (0=kp)∨(sk=0)
      r←GetProp con'IWA'
    ∇


    ∇ r←IWAAuth con;tok;cmd;rc;rr;kp
      err HANDLE←IWAStart 1 'NTLM' ''
      :Repeat
          err kp len tok←IWAGet HANDLE 1 200 200
          tok←len↑tok
          rc cmd←Send con tok
          rr←Wait cmd 10000
          tok←4⊃rr
          IWASet HANDLE(⍴tok)tok
      :Until 0=kp
      r←IWAName HANDLE 100
     ⍝ r←GetProp con'IWA'
    ∇
    ∇ r←toAv a;⎕IO
      ⎕IO←0
      r←⎕AV[((⎕NXLATE 0)⍳⍳256)[⎕AV⍳a]]
    ∇
    ∇ r←toAnsi a;⎕IO
      ⎕IO←0
      r←⎕AV[(⎕NXLATE 0)[⎕AV⍳a]]
    ∇

    ∇ r←IWAAuthVBtxt con;tok;rr;kp;header;size;tokout
      SetProp con'IWA'('NTLM' '')
      :Repeat
          header←''
          size←0
          tok←''
          :Repeat
              rr←Wait con 1000
              :If 0=⊃rr
                  :If size>0
                      tok,←4⊃rr
                  :Else
                      :If 16>⍴header
                          header,←(16-⍴header)↑4⊃rr
                      :EndIf
                      :If 16=⍴header         ⍝ header form '<IWA     nnnnn>'
                      :AndIf '<'=1↑header
                      :AndIf '>'=¯1↑header
                          size←2⊃⎕VFI 5↓15↑header
                          tok←16↓4⊃rr
     
                      :EndIf
                  :EndIf
              :EndIf
          :Until (size>0)∧size=⍴tok
          :If 0=⊃rr
              SetProp con'Token'(toAnsi tok)
              kp tokout←2⊃GetProp con'Token'
              :If kp=1
                  Send con('<IWA',(¯11↑(⍕⍴tokout)),'>')
                  Send con(toAv tokout)
              :Else
                  r←GetProp con'IWA'
                  Send con('<IWAc',(¯10↑(⍕⍴2⊃r)),'>')
                  Send con(2⊃r)
              :EndIf
          :Else
              kp←1
          :EndIf
      :Until 0=kp
     
    ∇


    :Class flate
        :field Public Shared LDRC                ⍝ Save a ref to DRC to be used from flate
        :field Public Shared defaultcomp ←¯1     ⍝ Default compression 0-9 or ¯1
        :field Public Shared defaultblocksize←2*15    ⍝ Default block size

        :field Public instance handle            ⍝ session handle
        :field Public instance direction         ⍝ 0= deflate, 1 = inflate
        :field Public instance comp              ⍝ compression level
        :field Public instance blocksize         ⍝ blocksize
        :field Public instance lastout

        ∇ r←IsAvailable
          :Access public shared
          :If 3=⎕NC'LDRC.cflate'
              r←1
          :Else
              r←0
          :EndIf
        ∇

        ∇ r←dir allflate arg;zz;handle
          r←⍬
          handle←0
          :Repeat
               ⍝  (1⌈⍴arg)↑   is a AIX workaround
              zz←LDRC.cflate dir(handle)((1⌈⍴arg)↑arg)(⍴arg)(defaultblocksize)(defaultblocksize)defaultcomp
              r,←(5⊃zz)↑4⊃zz
              handle←2⊃zz
              arg←⍬
          :Until (0=handle)∨(0=3⊃zz)∧(defaultblocksize>5⊃zz) ⍝ carry on until the input is processed and the we have not filled the last output buffer
         
        ∇

        ∇ r←instflate arg;zz
          r←⍬
          :Repeat
              ⍝  (1⌈⍴arg)↑   is a AIX workaround
              zz←LDRC.cflate direction(handle)((1⌈⍴arg)↑arg)(⍴arg)(blocksize)(blocksize)comp
              r,←(5⊃zz)↑4⊃zz
              arg←⍬
              handle←2⊃zz
              lastout←1 1 1 0 1/zz
          :Until (handle=0)∨(0=3⊃zz)∧(blocksize>5⊃zz) ⍝ carry on until the input is processed and the we have not filled the last output buffer
         
        ∇


        ∇ r←Deflate arg
          :Access public shared
         
          r←2 allflate arg
        ∇

        ∇ r←Inflate arg;zz
          :Access public shared
          r←3 allflate arg
        ∇

        ∇ make(d c b)
          :Access public
          :Implements constructor
          direction←d
          comp←c
          blocksize←b
          handle←0
        ∇

        ∇ make0
          :Access public
          :Implements constructor
          make(0 defaultcomp defaultblocksize)
        ∇

        ∇ make1(dir)
          :Access public
          :Implements constructor
          make(dir defaultcomp defaultblocksize)
        ∇

        ∇ make2(dir c)
          :Access public
          :Implements constructor
          make(dir c defaultblocksize)
        ∇

        ∇ EndOfInput
          :Access public
          direction+←2
        ∇

        ∇ r←EndOfOutput
          :Access public
          r←0=handle
        ∇

        ∇ r←Process arg;zz
          :Access public
         
          r←instflate arg
        ∇


    :endclass

    :Class X509Cert
        :field Public Shared LDRC          ⍝ Save a ref to DRC to be used from X509Cert
        :Field Private Instance _Cert←''       ⍝ Raw certificate
        :field private Instance _Key←''        ⍝ Raw certificate private key
        :Field Private Instance _usemsstoreapi ⍝ Use GNU unless this is set to 1
        :Field Private Instance _CertOrigin←'' ⍝ Where did this certificate come from
        :Field Private instance _KeyOrigin←''  ⍝ Where did the  private part come from
        :Field Private instance _ParentCert←'' ⍝ Parent certificate or ''

        tochar←{80=⎕DR 'A':⎕UCS ⍵ ⋄ ⎕AV[⎕IO+⍵]}

        :Property UseMSStoreAPI
        :Access Public Instance
            ∇ r←Get args
              r←_usemsstoreapi
            ∇
            ∇ Set args;z
              _usemsstoreapi←args.NewValue
              z←⎕EX¨'_Elements' '_Formatted' '_Extended'
            ∇
        :EndProperty

        :Property Cert
        :Access Public Instance
            ∇ r←Get args
              r←_Cert
            ∇
            ∇ Set args;z
              _Cert←args.NewValue
              z←⎕EX¨'_Elements' '_Formatted' '_Extended' 'DecodeOK'
            ∇
        :EndProperty

        :Property CertOrigin
        :Access Public Instance
            ∇ r←Get args
              r←_CertOrigin
            ∇
            ∇ Set args
              _CertOrigin←args.NewValue
            ∇
        :EndProperty

        :Property KeyOrigin
        :Access Public Instance
            ∇ r←Get args
              r←_KeyOrigin
            ∇
            ∇ Set args
              _KeyOrigin←args.NewValue
            ∇
        :EndProperty

        :Property ParentCert
        :Access Public Instance
            ∇ r←get args
              r←⍬
              :Trap 0
                  :If 0<_ParentCert.IsCert
                      r←_ParentCert
                  :EndIf
             
             
              :EndTrap
            ∇
            ∇ Set args
              :Trap 0
                  :If 0<args.NewValue.IsCert
                  :AndIf Elements.Issuer≡args.NewValue.Elements.Subject
                      _ParentCert←args.NewValue
                  :Else
                      'Not a parent certificate'⎕SIGNAL 11
                  :EndIf
              :Else
                  'Not a certificate'⎕SIGNAL 11
                  _ParentCert←⍬
              :EndTrap
             
            ∇
        :EndProperty


        PropertyNames←'Version' 'SerialNo' 'AlgorithmID' 'AlgorithmParams' 'Issuer' 'ValidFrom' 'ValidTo' 'Subject' 'KeyID' 'KeyParams' 'KeyLength' 'Key' 'IssuerID' 'SubjectID' 'Extensions'
        PropertyIndices←1 2 (3 1)(3 2)4 (5 1)(5 2)6 (7 1)(7 2)(7 3)(7 4) 8 9 10

        :Property Elements,Formatted,Extended
        :Access Public Instance
            ∇ r←get args;i;z;n;t
              i←¯1+'Elements' 'Formatted' 'Extended'⍳⊂args.Name
              :If 0≠⎕NC n←'_',args.Name ⋄ r←⍎n ⍝ Already decoded?
              :Else ⍝ We must decode it now
                  :If 0=1⊃z←LDRC.Certs'Decode'_Cert('Details'i),_usemsstoreapi/⊂'DecodeApi' 'store'
                      DecodeOK←1
                      r←⍎n,'←⎕NS '''''
                      t←PropertyIndices⊃¨⊂2 2⊃z
                      ⍎n,'.(',(⍕PropertyNames),')←t'
                      :If i≥0 ⋄ r.(KeyHex←(⎕D,⎕A)[1+2⊥⍉(((⍴Key)÷4),4)⍴Key]) ⋄ :EndIf
             
                      :If 3=⍴2⊃z ⋄ t←2 3⊃z ⋄ :Else ⋄ t←('' '' '')'' '' '' ⋄ :EndIf ⍝ MS Store?
                      r.((KeyProvider KeyContainer KeyProviderType)FriendlyName Description EnhancedKeyUsage)←t
                  :Else
                      (⍕z)⎕SIGNAL 11
                  :EndIf
              :EndIf
            ∇
        :EndProperty
        
          base64←{⎕IO ⎕ML←0 1             ⍝ Base64 encoding and decoding as used in MIME.
         
              chars←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
              bits←{,⍉(⍺⍴2)⊤⍵}                   ⍝ encode each element of ⍵ in ⍺ bits,
                                       ⍝   and catenate them all together
              part←{((⍴⍵)⍴⍺↑1)⊂⍵}                ⍝ partition ⍵ into chunks of length ⍺
         
              0=2|⎕DR ⍵:2∘⊥∘(8∘↑)¨8 part{(-8|⍴⍵)↓⍵}6 bits{(⍵≠64)/⍵}chars⍳⍵
                                       ⍝ decode a string into octets
         
              four←{                             ⍝ use 4 characters to encode either
                  8=⍴⍵:'=='∇ ⍵,0 0 0 0           ⍝   1,
                  16=⍴⍵:'='∇ ⍵,0 0               ⍝   2
                  chars[2∘⊥¨6 part ⍵],⍺          ⍝   or 3 octets of input
              }
              cats←⊃∘(,/)∘((⊂'')∘,)              ⍝ catenate zero or more strings
              cats''∘four¨24 part 8 bits ⍵
          }

        ∇ r←items GetDN DN;split;secs
        ⍝ Get an item from a distiguished name
         
          split←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}
          secs←'='split¨','split DN
          r←2⊃¨(secs,⊂'' '')[(1⊃¨secs)⍳items]
         
        ∇

        ∇ r←{name}Save path;name;filename;data;tn;ext;fixpath
          :Access public
          :Trap 0
              fixpath←{⍵,(~∨/'/\'∊⊃⌽⍵)⍴('/\'∩⍵),'/'}
              :If 0<⎕NC'name'
                  (name ext)←'.'{2↑1↓¨⍺{(⍺=⍵)⊂⍵}⍺,⍵}name,'.cer'
              :Else
                  name←⊃(⊂,'CN')GetDN ⎕THIS.Formatted.Subject
                  ext←'cer'
              :EndIf
         
              path←fixpath path
         
              :Select ##.##.lcase ext
              :CaseList 'cer' 'pem'
                  filename←path,name,'.',ext
                  data←⊃,/('X509 CERTIFICATE'{pre←{'-----',⍺,' ',⍵,'-----'} ⋄ (⊂'BEGIN'pre ⍺),⍵,⊂'END'pre ⍺}↓64{s←(⌈(⍴⍵)÷⍺),⍺ ⋄ s⍴(×/s)↑⍵}base64 Cert),¨⊂⎕UCS 10 13
              ⍝ remember to create the directory
                  tn←filename ⎕NCREATE 0
                  data ⎕NAPPEND tn 80
                  ⎕NUNTIE tn
         
              :Case 'der'
                  filename←path,name,'.',ext
                  tn←filename ⎕NCREATE 0
                  (_Cert)⎕NAPPEND tn 83
                  ⎕NUNTIE tn
              :Else
                  'Unknown Certificate format'⎕SIGNAL 11
              :EndSelect
              r←0
          :Else
              r←⎕EN
          :EndTrap
        ∇
            
        
        ∇ {r}←CopyCertificationChainFromStore;trustroot;trustca;rix;iix;⎕IO;foundroot;current
          :Access Public
          ⍝ Follow certificate chain from "⎕this" until a root certificate is found,
          ⍝ Updating the ParentCert Property so the Certificate Chain is complete if possible
         
          ⎕IO←1
         
          trustroot←DRC.X509Cert.ReadCertFromStore'root'
          trustca←DRC.X509Cert.ReadCertFromStore'CA'
          current←⎕THIS
         
          :Repeat
              :If foundroot←(⍴trustroot)≥rix←trustroot.Formatted.Subject⍳⊂current.Formatted.Issuer
              ⍝ we have found the root cert
                  current.ParentCert←rix⊃trustroot
         
              :ElseIf (⍴trustca)≥iix←trustca.Formatted.Subject⍳⊂current.Formatted.Issuer
               ⍝ we have found an intermediate  cert
                  current.ParentCert←iix⊃trustca
                  current←current.ParentCert
              :Else
                  'Unable to reach a root certificate'⎕SIGNAL 999
              :EndIf
         
          :Until foundroot
          r←⍴Chain
        ∇
            

        ∇ chain←Chain;pc
          :Access Public
          chain←,⊂⎕THIS
          pc←ParentCert
          :While ⍬≢pc
          :AndIf 0<pc.IsCert
          :AndIf (⊃¯1↑chain).Elements.Subject≢pc.Elements.Subject
              chain,←pc
              pc←pc.ParentCert
          :EndWhile
        ∇

        ∇ arg←AsArg
          :Access Public
          arg←⍬
          :If ''≢_Cert
              arg,←⊂'PublicCertData'Chain.Cert
          :ElseIf ''≢_CertOrigin
              arg,←⊂'PublicCertFile'_CertOrigin
          :EndIf
          :If ''≢_Key
              arg,←⊂'PrivateKeyData'_Key
          :ElseIf ''≢_KeyOrigin
              arg,←⊂'PrivateKeyFile'(_KeyOrigin)
          :EndIf
        ∇

        ∇ r←IsCert;z
          :Access public
          :If 2=⎕NC'DecodeOK'
              r←DecodeOK
          :Else
              r←(0=⊃z←LDRC.Certs'Decode'_Cert)
              DecodeOK←r
          :EndIf
          r+←(r=1)∧(_KeyOrigin≢'')∨_Key≢''
         
        ∇

        ∇ Make0
          :Access Public
          :Implements Constructor
          Cert←''
          _Key←''
          _usemsstoreapi←0
          _CertOrigin←_KeyOrigin←('DER' '')
         
        ∇

        ∇ Make1 cert
          :Access Public
          :Implements Constructor
         
          :If 1≠≡cert ⋄ cert←1⊃cert ⋄ :EndIf
          Cert←cert
          _usemsstoreapi←0
          _CertOrigin←_Key←_KeyOrigin←''
        ∇

        ∇ Make2(cert origin)
          :Access Public
          :Implements Constructor
          Cert←cert
          _usemsstoreapi←0
          _CertOrigin←origin
          :If 'MSStore'≡1⊃origin
              _KeyOrigin←origin
          :EndIf
        ∇

        ∇ Make3(cert certorigin keyorigin)
          :Access Public
          :Implements Constructor
          Cert←cert
          _usemsstoreapi←0
          _CertOrigin←certorigin
          _KeyOrigin←keyorigin
         
        ∇

        ∇ r←base Decode code;ix;bits;size;s
          ix←¯1+base⍳code
         
          bits←,⍉((2⍟⍴base)⍴2)⊤ix
          size←{(⌊(¯1+⍺+⊃⍴⍵)÷⍺),⍺}
         
          s←8 size bits
         
          r←(8⍴2)⊥⍉s⍴(×/s)↑bits
          r←(-0=¯1↑r)↓r
        ∇
        ∇ certs←ReadCertUrls;certurls;list
          :Access Public shared
          certurls←LDRC.Certs'Urls' ''
          :If 0=1⊃certurls
          :AndIf 0<1⊃⍴2⊃certurls
              certs←{⎕NEW X509Cert((4⊃⍵)('URL'(1⊃⍵))('URL'(2⊃⍵)))}¨↓2⊃certurls
          :Else
              certs←⍬
          :EndIf
        ∇

        ∇ certs←ReadCertFromStore storename;cs
          :Access  public shared
         
          cs←LDRC.Certs'MSStore'storename
          :If 0=1⊃cs
          :AndIf 0<⍴2⊃cs
              certs←⎕NEW¨(2⊃cs){X509Cert(⍺ ⍵)}¨⊂'MSStore'storename
          :Else
              certs←⍬
          :EndIf
        ∇

        ∇ certs←ReadCertFromFolder wildcardfilename;files;f;filelist
          :Access public shared
          filelist←1 LDRC.Files.List wildcardfilename
          files←filelist[;1]
          certs←⍬
          :For f :In files
              certs,←ReadCertFromFile f
          :EndFor
        ∇

        ∇ certs←ReadCertFromFile filename;c;base64;tie;size;cert;ixs;ix;d;pc;temp
          :Access public shared
          certs←⍬
          c←'-----BEGIN X509 CERTIFICATE-----' '-----BEGIN CERTIFICATE-----'
          base64←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
          tie←filename ⎕NTIE 0
          size←⎕NSIZE tie
          cert←⎕NREAD tie 82 size
          ixs←c{⊃,/{(⍳⍴⍵),¨¨⍵}⍺{(⍺⍷⍵)/⍳⍴⍵}¨⊂⍵}cert
          :If 0<⍴ixs
              :For ix :In ixs
                  d←((2⊃ix)+⍴⊃c[1⊃ix])↓cert
                  d←(¯1+⊃d⍳'-')↑d
                  d←(d∊base64)/d
                  ⍝d←tochar base64 Decode d
                  d←base64 Decode d
                  certs,←⎕NEW X509Cert(d('DER'filename))
         
                  ⍝c.Origin←'DER' filename
                  ⍝certs,←c
              :EndFor
          :Else
              cert←⎕NREAD tie 83 size 0
             ⍝ cert←⎕AV[⎕IO+256|cert+256]
              certs,←⎕NEW X509Cert(cert('DER'filename))
              ⍝c.Origin←'DER' filename
              ⍝certs,←c
          :EndIf
          ⎕NUNTIE tie
          certs←LDRC.SetParents certs
        ∇

    :EndClass
    :Namespace Files

        ⎕IO ⎕ML←1 0
        lastoccur←{ ⍺[{⍵⍳⌊/⍵}(⌽⍵)⍳⍺]    }

        ∇ r←{full}List path;z;rslt;handle;next;ok;attrs;⎕IO;FindFirstFileX;FindNextFileX;FindClose;FileTimeToLocalFileTime;FileTimeToSystemTime;GetLastError;slash;prefix;fix
    ⍝ Return matrix containing
    ⍝ [;0] Name [;1] Length [;2] LastAccessTime [;3] IsDirectory
         
          ⎕IO←0
         
          slash←⊃(path,'\/')∩'\/'
          slash←'\/'lastoccur path
          ⍎(0=⎕NC'full')/'full←0'
          :If {(⍵⍳'*')≥⍴⍵}path
              prefix←full/path,slash
              path←path,slash,'*'
          :Else
              prefix←full/(path{(-(⌽⍺)⍳⍵)↓⍺}slash)
         
          :EndIf
          fix←{prefix,⍵}
         
         
          :Select 0⊃'.'⎕WG'APLVersion'
          :Case 'Linux'
              rslt←↑⎕SH'ls -al --time-style=full-iso ',path
              rslt←' ',('total '≡6⍴rslt)↓[0]rslt
              →(0=1↑⍴r←((1↑⍴rslt),4)⍴0)⍴0
         
              z←∧⌿' '=rslt ⍝ entirely blank columns
              z←z∧10>+\z    ⍝ Do not split file names
              rslt←z⊂rslt
              r[;3]←'d'=(0⊃rslt)[;1]                 ⍝ IsDirectory
              r[;1]←(~r[;3])×1⊃⎕VFI,4⊃rslt ⍝ Size
              z←,(5⊃rslt),6⊃rslt ⋄ ((z∊'-:')/z)←' ' ⋄ z←((1↑⍴r),6)⍴1⊃⎕VFI z
              r[;2]←↓⌊z,1000×1|z[;5]                ⍝ Add msec to Timestamp
              r[;0]←fix¨{(-+/∧\' '=⌽⍵)↓¨↓⍵}0 1↓8⊃rslt    ⍝ Name
         
          :Case 'Windows'
      ⍝ See DirX for explanations of results of _FindNextFile etc
              _FindDefine
              handle rslt←_FindFirstFile path
              :If 0=handle
                  ('ntdir error:',⍕rslt)⎕SIGNAL 102      ⍝ file not found
              :EndIf
              rslt←,⊂rslt
              :While 1=0⊃ok next←_FindNextFile handle
                  rslt,←⊂next
              :EndWhile
              :If 0 18∨.≠ok next
                  ('ntdir error:',⍕next)⎕SIGNAL 11   ⍝ DOMAIN
              :EndIf
              ok←FindClose handle
              rslt←↓[0]↑rslt
              →(0=1↑⍴r←((1↑⍴0⊃rslt),4)⍴0)⍴0
              (0⊃rslt)←⍉attrs←(32⍴2)⊤0⊃rslt                ⍝ Get attributes into bits
              r[;3]←(0⊃rslt)[;27]              ⍝ IsDirectory?
              r[;1]←0(2*32)⊥⍉↑4⊃rslt          ⍝ combine size elements
              r[;2]←_Filetime_to_TS¨3⊃rslt     ⍝ As ⎕TS vector
              r[;0]←fix¨6⊃rslt                     ⍝ Name
          :Else
              ∘Unsupported O/S
          :EndSelect
          r←r[⍋↑r[;0];]
        ∇

        ∇ r←text AppendText name;tn
     ⍝ Append text to existing file (must be single byte text)
         
          tn←name ⎕NTIE 0
          r←text ⎕NAPPEND tn(⎕DR' ')
          ⎕NUNTIE tn
        ∇

        ∇ (tn name)←CreateTemp pattern;z;i;name;folder
     ⍝ Create a temp file. Pattern e.g. c:\folder\*.ext
          'Exactly ONE * required'⎕SIGNAL(1≠⍴i←{⍵/⍳⍴⍵}'*'=pattern)/11
          folder←(1-⌊/(⌽pattern)⍳'\/')↓pattern
          i←pattern⍳'*'
         
          :Trap 102 ⋄ z←(List pattern)[;1]
          :Else ⋄ z←⊂'' ⋄ :EndTrap
         
          name←1⊃((⊂((i-1)↑pattern),'temp'),¨(⍕¨⍳1+⍴z),¨⊂i↓pattern)~z
          tn←name ⎕NCREATE 0
        ∇

        ∇ {protect}Copy FmTo;CopyFileX;GetLastError ⍝ Copy file Fm -> To
          :If 0=⎕NC'protect'     ⍝ Copy fails if <protect> and 'To' exists.
              protect←0          ⍝ Default unprotected copy.
          :EndIf
          'CopyFileX'⎕NA'I kernel32.C32|CopyFile* <0T <0T I'
          :If 0=CopyFileX FmTo,protect
              ⎕NA'I4 kernel32.C32|GetLastError'
              11 ⎕SIGNAL⍨'CopyFile error:',⍕GetLastError
          :EndIf
        ∇

        ∇ Delete name;DeleteFileX;GetLastError
          :Select 1⊃'.'⎕WG'APLVersion'
          :Case 'Linux'
              ⎕SH'rm ',name
          :Case 'Windows'
              'DeleteFileX'⎕NA'I kernel32.C32|DeleteFile* <0T'
              :If 0=DeleteFileX⊂name
                  ⎕NA'I4 kernel32.C32|GetLastError'
                  11 ⎕SIGNAL⍨'DeleteFile error:',⍕GetLastError
              :EndIf
          :Else
              ∘ ⍝ Unsupported O/S
          :EndSelect
        ∇

        ∇ rslt←{amsk}Dir path;handle;next;ok;⎕IO;attrs;FindFirstFileX;FindNextFileX;FindClose;FileTimeToLocalFileTime;FileTimeToSystemTime;GetLastError
          'FIX ME'⎕SIGNAL 11
     ⍝ Amsk is a 32 element bool attribute mask.
     ⍝ Only files with attributes corresponding to 1-s in the mask will be returned.
     ⍝ '*'s mark default attribute mask.
     ⍝
     ⍝        * [31] <=> READONLY
     ⍝          [30] <=> HIDDEN
     ⍝        * [29] <=> SYSTEM
     ⍝          [28] <=> undocumented
     ⍝        * [27] <=> DIRECTORY
     ⍝        * [26] <=> ARCHIVE
     ⍝          [25] <=> DEVICE
     ⍝        * [24] <=> NORMAL - only set if no other bits are set
     ⍝        * [23] <=> TEMPORARY
     ⍝        * [22] <=> SPARSE FILE
     ⍝        * [21] <=> REPARSE POINT
     ⍝        * [20] <=> COMPRESSED
     ⍝        * [19] <=> OFFLINE
     ⍝        * [18] <=> NOT CONTENT INDEXED
     ⍝        * [17] <=> ENCRYPTED
     ⍝        * rest <=> undocumented (but in the default set so that
     ⍝                   Microsoft can extend them)
    ⍝ rslt is a vector of character vectors of filenames
         
          ⎕IO←0
          :If 0=⎕NC'amsk'
              amsk←~(⍳32)∊30 28 25   ⍝ Default attribute mask.
          :EndIf
          _FindDefine
          handle rslt←_FindFirstFile path
          :If 0=handle
              ('ntdir error:',⍕rslt)⎕SIGNAL 102      ⍝ file not found
          :EndIf
          rslt←,⊂rslt
          :While 1=0⊃ok next←_FindNextFile handle
              rslt,←⊂next
          :EndWhile
          :If 0 18∨.≠ok next
              ('ntdir error:',⍕next)⎕SIGNAL 11       ⍝ DOMAIN
          :EndIf
          ok←FindClose handle
          rslt←↓[0]↑rslt
          attrs←(32⍴2)⊤0⊃rslt                        ⍝ Get attributes into bits
          rslt←(amsk∧.≥attrs)⌿6⊃rslt                 ⍝ bin unwanted files and info
        ∇

        ∇ rslt←{amsk}DirX path;handle;next;ok;attrs;⎕IO;FindFirstFileX;FindNextFileX;FindClose;FileTimeToLocalFileTime;FileTimeToSystemTime;GetLastError
          'FIX ME'⎕SIGNAL 11
     ⍝ Amsk is a 32 element bool attribute mask.
     ⍝ Only files with attributes corresponding to 1-s in the mask will be returned.
     ⍝ Amsk defaults to all attributes.
     ⍝ 0⊃rslt <=> 32 column boolean matrix of attribute bits
     ⍝          [;31] <=> READONLY
     ⍝          [;30] <=> HIDDEN
     ⍝          [;29] <=> SYSTEM
     ⍝          [;28] <=> undocumented
     ⍝          [;27] <=> DIRECTORY
     ⍝          [;26] <=> ARCHIVE
     ⍝          [;25] <=> undocumented
     ⍝          [;24] <=> NORMAL - only set if no other bits are set
     ⍝          [;23] <=> TEMPORARY
     ⍝          [;22] <=> SPARSE FILE
     ⍝          [;21] <=> REPARSE POINT
     ⍝          [;20] <=> COMPRESSED
     ⍝          [;19] <=> OFFLINE
     ⍝          [;18] <=> NOT CONTENT INDEXED
     ⍝          [;17] <=> ENCRYPTED
     ⍝          rest  <=> undocumented
     ⍝ 1⊃rslt <=> 7 column numeric matrix expressing the file creation time in ⎕TS format
     ⍝         if the file system does not support this then all columns are 0
     ⍝ 2⊃rslt <=> 7 column numeric matrix expressing the file last access time in ⎕TS format
     ⍝         if the file system does not support this then all columns are 0
     ⍝ 3⊃rslt <=> 7 column numeric matrix expressing the file last write time in ⎕TS format
     ⍝ 4⊃rslt <=> numeric vector giving the file size accurate up to 53 bits
     ⍝ 5⊃rslt <=> vector of character vectors giving the file names
     ⍝ 6⊃rslt <=> vector of character vectors giving the 8.3 file name for file systems
     ⍝         where it is appropriate and different from the file name
          ⎕IO←0
          :If 0=⎕NC'amsk'
              amsk←32⍴1
          :EndIf
          _FindDefine
          handle rslt←_FindFirstFile path
          :If 0=handle
              ('ntdir error:',⍕rslt)⎕SIGNAL 102      ⍝ file not found
          :EndIf
          rslt←,⊂rslt
          :While 1=0⊃ok next←_FindNextFile handle
              rslt,←⊂next
          :EndWhile
          :If 0 18∨.≠ok next
              ('ntdir error:',⍕next)⎕SIGNAL 11   ⍝ DOMAIN
          :EndIf
          ok←FindClose handle
          rslt←↓[0]↑rslt
          (0⊃rslt)←⍉attrs←(32⍴2)⊤0⊃rslt                ⍝ Get attributes into bits
          rslt←(amsk∧.≥attrs)∘⌿¨rslt                ⍝ bin unwanted files and info
          rslt[1 2 3]←↑¨_Filetime_to_TS¨¨rslt[1 2 3]    ⍝ put times into ⎕ts format
          (4⊃rslt)←0(2*32)⊥⍉↑4⊃rslt                    ⍝ combine size elements
          rslt/⍨←5≠⍳8                               ⍝ bin the reserved elements
        ∇

        ∇ r←Exists name
     ⍝ Does file exist?
         
          r←1
          :Trap 19 22
              ⎕NUNTIE name ⎕NTIE 0
          :Else
              r←0
          :EndTrap
        ∇

        ∇ r←GetCurrentDirectory;GCD;GetLastError
     ⍝ Get Current Directory using Win32 API
         
          'GCD'⎕NA'I kernel32.C32|GetCurrentDirectory* I4 >0T'
          :If 0≠1⊃r←GCD 256 256
              r←2⊃r
          :Else
              ⎕NA'I4 kernel32.C32|GetLastError'
              11 ⎕SIGNAL⍨'GetCurrentDirectory error:',⍕GetLastError
          :EndIf
        ∇

        ∇ r←GetText name;tn
     ⍝ Read a text file as single byte text
         
          tn←name ⎕NTIE 0
          r←⎕NREAD tn(⎕DR' ')(⎕NSIZE tn)
          ⎕NUNTIE tn
        ∇

        ∇ MkDir path;CreateDirectory;GetLastError;err
      ⍝ Create a folder using Win32 API
         
          ⎕NA'I kernel32.C32|CreateDirectory* <0T I4' ⍝ Try for best function
          →(0≠CreateDirectory path 0)⍴0 ⍝ 0 means "default security attributes"
          ⎕NA'I4 kernel32.C32|GetLastError'
          err ⎕SIGNAL⍨'CreateDirectory error:',⍕err←GetLastError
        ∇

        ∇ Move filenames;MoveFileX;MoveFileExA;GetLastError;err
          ⎕NA'I kernel32.C32|MoveFileEx* <0T <0T I4' ⍝ Try for best function
          :If 0≠MoveFileExA filenames,3 ⍝ REPLACE_EXISTING (1) + COPY_ALLOWED (2)
              :Return
          :EndIf
          ⎕NA'I4 kernel32.C32|GetLastError'
          :Select err←GetLastError
          :Case 120                     ⍝ ERROR_CALL_NOT_IMPLIMENTED
              'MoveFileX'⎕NA'I Kernel32.C32|MoveFile* <0T <0T' ⍝ accept 2nd best - win 95
              :If 0≠MoveFileX filenames
                  :Return
              :EndIf
              err←GetLastError
          :EndSelect
          11 ⎕SIGNAL⍨'MoveFile error:',⍕err
        ∇

        ∇ r←text PutText name;tn
     ⍝ Write text to file (must be single byte text)
         
          :Trap 0
              tn←name ⎕NCREATE 0
          :Else
              tn←name ⎕NTIE 0
              0 ⎕NRESIZE tn
          :EndTrap
         
          r←text ⎕NAPPEND tn(⎕DR' ')
          ⎕NUNTIE tn
        ∇

        ∇ RmDir path;RemoveDirectoryA;GetLastError
     ⍝ Remove folder using Win32 API
         
          ⎕NA'I kernel32.C32|RemoveDirectory* <0T'
          →(0≠RemoveDirectoryA,⊂path)⍴0
          ⎕NA'I4 kernel32.C32|GetLastError'
          11 ⎕SIGNAL⍨'RemoveDirectory error:',⍕GetLastError
        ∇

        ∇ SetCurrentDirectory path;SCD;GetLastError
     ⍝ Set Current Directory using Win32 API
         
          'SCD'⎕NA'I kernel32.C32|SetCurrentDirectory* <0T'
          →(0≠SCD,⊂path)⍴0
          ⎕NA'I4 kernel32.C32|GetLastError'
          11 ⎕SIGNAL⍨'SetCurrentDirectory error:',⍕GetLastError
        ∇

        ∇ rslt←_Filetime_to_TS filetime;⎕IO
          :If 1≠0⊃rslt←FileTimeToLocalFileTime filetime(⎕IO←0)
          :OrIf 1≠0⊃rslt←FileTimeToSystemTime(1⊃rslt)0
              rslt←0 0                   ⍝ if either call failed then zero the time elements
          :EndIf
          rslt←1 1 0 1 1 1 1 1/1⊃rslt    ⍝ remove day of week
        ∇

        ∇ _FindDefine;WIN32_FIND_DATA
          WIN32_FIND_DATA←'{I4 {I4 I4} {I4 I4} {I4 I4} {U4 U4} {I4 I4} T[260] T[14]}'
          'FindFirstFileX'⎕NA'I4 kernel32.C32|FindFirstFile* <0T >',WIN32_FIND_DATA
          'FindNextFileX'⎕NA'U4 kernel32.C32|FindNextFile* I4 >',WIN32_FIND_DATA
          ⎕NA'kernel32.C32|FindClose I4'
          ⎕NA'I4 kernel32.C32|FileTimeToLocalFileTime <{I4 I4} >{I4 I4}'
          ⎕NA'I4 kernel32.C32|FileTimeToSystemTime <{I4 I4} >{I2 I2 I2 I2 I2 I2 I2 I2}'
          ⎕NA'I4 kernel32.C32|GetLastError'
        ∇

        ∇ rslt←_FindFirstFile name;⎕IO
          rslt←FindFirstFileX name(⎕IO←0)
          :If ¯1=0⊃rslt                   ⍝ INVALID_HANDLE_VALUE
              rslt←0 GetLastError
          :Else
              (1 6⊃rslt)_FindTrim←0        ⍝ shorten the file name at the null delimiter
              (1 7⊃rslt)_FindTrim←0        ⍝ and for the alternate name
          :EndIf
        ∇

        ∇ rslt←_FindNextFile handle;⎕IO
          rslt←FindNextFileX handle(⎕IO←0)
          :If 1≠0⊃rslt
              rslt←0 GetLastError
          :Else
              (1 6⊃rslt)_FindTrim←0             ⍝ shorten the filename
              (1 7⊃rslt)_FindTrim←0             ⍝ shorten the alternate name
          :EndIf
        ∇

        ∇ name←name _FindTrim ignored;⎕IO
     ⍝ Truncates a character vector at the null delimiting byte.
     ⍝ The null is not included in the result.
          ⎕IO←0
          name↑⍨←name⍳⎕UCS 0
        ∇

    :EndNamespace


:EndNamespace