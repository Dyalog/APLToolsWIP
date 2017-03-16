:Namespace Conga

    PATH←''      ⍝ To the Conga DLL
    ⍙naedfns←⍬   ⍝ ⎕NA'd function list

    enc←{(326≠⎕dr ⍵)∧1=≡⍵:,⊂⍵ ⋄ ⍵}
    defaults←{⍺,(⍴,⍺)↓⍵}

    ErrorTable←94 3⍴  0 'SUCCESS' '' 100 'TIMEOUT' '' 1000 'ERR_LOAD_DLL' '' 1001 'ERR_LENGTH' '' 1002 'ERR_RANK' '' 1003 'ERR_VALUE' '' 1004 'ERR_DOMAIN' '' 1005 'ERR_NONCE' '' 1006 'ERR_ROOT_NOT_FOUND' '' 1007 'ERR_PARENT_NOT_FOUND' '' 1008 'ERR_INVALID_OBJECT' '' 1009 'ERR_NAME_IN_USE' '' 1010 'ERR_OBJECT_NOT_FOUND' '' 1011 'ERR_ROOT_EXISTS' '' 1012 'ERR_MEMORY_ALLOC' '' 1013 'ERR_UNKNOWN_CLASS' '' 1014 'ERR_UNKNOWN_ACTION' '' 1015 'ERR_UNSUPPORTED' '' 1016 'ERR_OPEN_BIND' '' 1017 'ERR_OPEN_SINGLE' '' 1018 'ERR_OPEN_DOUBLE' '' 1019 'ERR_VAR_DEF' '' 1020 'ERR_USE_DEFAULT' '' 1021 'ERR_INVALID_IDENTIFIER' '' 1022 'ERR_INVALID_MODIFIER' '' 1023 'ERR_INVALID_NAME' '' 1024 'ERR_INVALID_BROTHER' '' 1025 'ERR_UNKNOWN_SERVICE' '' 1026 'ERR_CLOSE_BUFFER' '' 1027 'ERR_COLUMN_WIDTH' '' 1028 'ERR_OPEN_PARA' '' 1029 'ERR_UNKNOWN_NET' '' 1030 'ERR_COLUMN' '' 1031 'ERR_MAX_CURSORS' '' 1032 'ERR_APL_TO_BUFFER' '' 1033 'ERR_PROFF' '' 1034 'ERR_BIND_TO_LARGE' '' 1035 'ERR_UNKNOWN_TYPE' '' 1036 'ERR_CONVERSION' '' 1037 'ERR_OPTION' '' 1038 'ERR_INDEX' '' 1039 'ERR_FILE' '' 1040 'ERR_PARENT' '' 1041 'ERR_OBJTYPE' '' 1042 'ERR_SIZE' '' 1043 'ERR_ALLREADY_INITIALIZED' '' 1044 'ERR_NOT_INITIALIZED' '' 1045 'ERR_ARG_INVALID' '' 1046 'ERR_ARG_MISSING' '' 1047 'ERR_ARG_STOPLIST' '' 1048 'ERR_DECF' '' 1100 'ERR_NEW_CMD_SOCKET' '/* Create New Command socket */' 1101 'ERR_NEW_DATA_SOCKET' '/* Create New Data socket */' 1102 'ERR_LISTEN' '/* Could not make socket listen */' 1103 'ERR_STATE' '/* Object have invalid state for this action */' 1104 'ERR_SEND' '/* Could not send data*/' 1105 'ERR_RECV' '/* Could not receive data */' 1106 'ERR_INVALID_HOST' '/* Host identification not resolved */' 1107 'ERR_INVALID_SERVICE' '/* Service identification not resolved */' 1108 'ERR_TIMEOUT' '/* Request timed out */' 1109 'ERR_SEND_CREQ' '/* Could not send CREQ to host */' 1110 'ERR_CONNECT_CMD' '/* Could not connect to host cmd port */' 1111 'ERR_CONNECT_DATA' '/* Could not connect to host data port */' 1112 'ERR_CONNECT_NACK' '/* Host refused connection */' 1113 'ERR_RECV_CMDANSWER' '/* Could not receive CMD answer from host */' 1114 'ERR_RECV_CREQ' '/* Could not receive CREQ */' 1115 'ERR_NOT_CREQ' '/* Received packet not a CREQ */' 1116 'ERR_SOCK_PORT' '/* Could not retrive socket port */' 1117 'ERR_SEND_PORT' '/* Could not send port packet to client */' 1118 'ERR_SEND_NACK' '/* Could not send nack packet to client */' 1119 'ERR_CLOSED' '/* Socket Closed while receiving */' 1120 'ERR_ACCEPT' '/* Could not accept socket  */' 1121 'ERR_THREAD_NOT_FOUND' '/* Thread not found */' 1122 'ERR_WAIT_SEM' '/* Wait did not return WAIT_OBJECT_0 or WAIT_TIMEOUT*/' 1123 'ERR_SOMEBODY_WAITING' '/* Another thread is allready waiting*/' 1124 'ERR_WORKSYNC_RECV' '' 1125 'ERR_NEW' '' 1126 'ERR_UNKNOWN_ANSWER' '/* Received an asnwer that cannot be matched with command.*/' 1127 'ERR_OBJECT_ACTIVITY' '/* Cannot delete object because of TCP/IP activity */' 1128 'ERR_NEW_THREAD' '/* Error creating new thread */' 1129 'ERR_NEW_SEMAPHORE' '/* Error creating new semaphore */' 1130 'ERR_WRONG_MAGIC' '/* Package with wrong magic received */' 1131 'ERR_ARCHITECTURE' '/* The architecture of the Z passed is not recognized */' 1132 'ERR_INVALID_ADDR' '/* We are unable to get information on the socket */' 1133 'ERR_FORK' '/* Conga have been forked and the workthread in the copy have ended */'  1201 'ERR_TLSHANDSHAKE' '/* unable to complete a TLS handshake with the peer */'  1202 'ERR_INVALID_PEER_CERTIFICATE' '/* The peers certificate is not valid */'  1203 'ERR_COULD_NOT_LOAD_CERTIFICATE_FILES' '/* Either the specified certificate file or private key file is not valid or could not be found. */'  1204 'ERR_INITIALISING_TLS' '/* There was an error initialising GnuTLS. */' 1205 'ERR_NO_SSL_SUPPORT' '/* There is no SSL support in this build of the conga DLL */'   1206 'ERR_HANDSHAKE_NOT_COMPLETED'    '/* GNU TLS HandShake did not complete  */' 1207 'ERR_INVALID_CERTIFICATE' '/* Cannot decode certificate */' 1300 'ERR_CERT_COUNT_FAILED' '/* Failed to count systems stores */'  1301 'ERR_CERT_NOT_FOUND' '/* Failed to find cert in certificate stores */'
    ErrorTable⍪←2 3⍴ 1134 'ERR_CALL_FAILED' '/* Operating System Call failed*/' 1135 'ERR_MAX_BLOCK_SIZE' '/* Max block size exeeded */'
    DllVer←'30'
 
    asAv←{⎕av[(⎕nxlate 0)⍳¯1+⎕av⍳⍵]}
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

    ∇ r←Certs a
      ⍝ Working with certificates.
      ⍝ ListMSStores
      ⍝ MSStore storename Issuer subject details api password
      ⍝ Folder not implemented
      ⍝ DER  not implemented
      ⍝ PK#12 not implemented
      r←check ⍙CallR RootName'ACerts'a 0
    ∇

    ∇ r←DefaultXlate;⎕IO;x1;x2
    ⍝ Retrieve Default translate tables for Dyalog APL
     
      ⎕IO←0
      x1←⎕NXLATE 0
      x2←x1⍳⍳⍴x1
     
      r←'DYA_IN' 'ASCII'(⎕AV[x1])(⎕AV[x2])
    ∇

    ∇ r←LoadSharedLib path;unicode;mac;win;bit64;filename;dirsep;z;dllname
      :If 3=⎕NC'⍙InitRPC' ⍝ Library already loaded
          r←0 'Conga already loaded'
      :Else ⍝ Not loaded
          {}⎕WA  ⍝ If there is garbage holding the shared library loaded get rid of it
          unicode←⊃80=⎕DR' '
          mac win bit64←∨/¨'Mac' 'Windows' '64'⍷¨⊂1⊃'.'⎕WG'APLVersion'
     ⍝ Dllname is Conga[x64 if 64-bit][Uni if Unicode][.so if UNIX]
          filename←'conga',DllVer,(⊃'__CU'[⎕IO+unicode]),(⊃('32' '64')[⎕IO+bit64]),⊃('' '.so' '.dylib')[⎕IO+mac+~win]
          dirsep←'/\'[⎕IO+win]
          :If win
             ⍝ if path is empty windows finds the .dll next to the .exe
              PATH←DefPath path
          :Else
          ⍝ if unix/linux rely on the setting of LIBPATH/LD_LIBRARY_PATH
              PATH←''
          :EndIf
          s←''
     
          :Trap 0
              ⍙naedfns←⍬
              dllname←'I4 "',PATH,filename,'"|'
     
              ⍙naedfns,←⊂'⍙CallR'⎕NA dllname,'Call& <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
              ⍙naedfns,←⊂'⍙CallRL'⎕NA dllname,'Call& <0T1 <0T1 =Z <Z'  ⍝ Left input
              ⍙naedfns,←⊂'⍙CallRnt'⎕NA dllname,'Call <0T1 <0T1 =Z <U',⍕4×1+bit64  ⍝ No left arg
              ⍙naedfns,←⊂'⍙CallRLR'⎕NA dllname,'Call1& <0T1 <0T1 =Z >Z' ⍝ Left output
              ⍙naedfns,←⊂'KickStart'⎕NA dllname,'KickStart& <0T1'
              ⍙naedfns,←⊂'SetXlate'⎕NA dllname,'SetXLate <0T <0T <C[256] <C[256]'
              ⍙naedfns,←⊂'GetXlate'⎕NA dllname,'GetXLate <0T <0T >C[256] >C[256]'
              :Trap 0     
                  ⍙naedfns,←⊂'⍙Version' ⎕na dllname,'Version >I4[3]'
                  ⍙naedfns,←⊂⎕NA'F8',2↓dllname,'Micros'
                  ⍙naedfns,←⊂⎕NA dllname,'cflate  I4  =P  <U1[] =U4 >U1[] =U4 I4'
              :EndTrap
              :Trap 0
                  z←InitRawIWA dllname
              :EndTrap
              ⍙naedfns,←⊂'⍙InitRPC'⎕NA dllname,'Init <0T1 <0T1'
     
          :EndTrap
     
     
          :If 3=⎕NC'⍙InitRPC'
              r←0('Conga loaded from: ',PATH,filename)
          :Else
              z←⎕EX¨⍙naedfns
              r←1000('Unable to find DLL "',filename,'"')('Tried: ',,⍕Path)
          :EndIf
      :EndIf
    ∇

    ∇ UnloadSharedLib;z
      z←⎕EX ⍙naedfns
      ⍙naedfns←⍬
    ∇
                    
    ∇ ref←FindInst rootname;inst;ix
      inst←⎕INSTANCES⊃⊃⎕CLASS DRC
      :If 0<⍴inst
      :AndIf (ix←inst.RootName⍳⊂rootname)≤⍴inst
          ref←inst[ix]
      :Else
          ref←⍬
      :EndIf
     
    ∇
    
    ⍝ Factory Functions that return instances of a Class
    
    ⍝ Returns an instance of DRC if unname default instance is returned
    ∇ ref←Init arg;path;rootname;inst;ix
      (path rootname)←(enc arg)defaults'' 'DRC'
      :If 0=⊃LoadSharedLib path
          :If ⍬≡ref←FindInst rootname
              ref←⎕NEW DRC(⎕THIS path rootname)
          :EndIf
      :Else
          'Unable to load sharedlib'⎕SIGNAL 999
      :EndIf
    ∇
      
    ⍝ return an instance of a server
    ∇ ref←{DRCref}Srv arg;service;conclass;address;extra
      :If 0=⎕NC'DRCref'
      :OrIf DRCref≡⍬
          DRCref←Init''
      :EndIf
      (service conclass address extra)←(enc arg)defaults 5000 Connection''(⎕NS'')
      ref←⎕NEW Server(DRCref service conclass address extra)
    ∇                                  

    ⍝ returns an instance of a Client
    ∇ ref←{DRCref}Clt arg;address;service;timeout
      :If 0=⎕NC'DRCref'
      :OrIf DRCref≡⍬
          DRCref←Init''
      :EndIf
     
      (address service timeout)←(enc arg)defaults'localhost' 5000 10000
      ref←⎕NEW Client(DRCref address service timeout)
    ∇

    ⍝ returns an instance of a X509
    ∇ ref←{DRCref}X509 arg;address;service;timeout
      :If 0=⎕NC'DRCref'
      :OrIf DRCref≡⍬
          DRCref←Init''
      :EndIf
     
      ref←⎕NEW X509Cert(DRCref, enc arg)
    ∇

:EndNamespace
