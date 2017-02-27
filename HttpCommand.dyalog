:Class HttpCommand
⍝ Description::
⍝ HttpCommand is a stand alone utility to issue HTTP commands and return their results.
⍝ HttpCommand can be used to retrieve the contents of web pages, issue calls to web services,
⍝ and communicate with any service which uses the HTTP protocol for communications.
⍝
⍝ N.B. requires Conga - the TCP/IP utility library
⍝
⍝ Overview::
⍝ HttpCommand can be used in two ways:
⍝   1) Using ⎕NEW - this allows you to specify the command's parameters without having to
⍝                   cram them into a single function or constructor invocation.
⍝        h←⎕NEW HttpCommand                            ⍝ create a new instance
⍝        h.(Command URL)←'get' 'www.dyalog.com'        ⍝ set the command parameters
⍝        r←h.Run                                       ⍝ run the command
⍝
⍝   2) Using the shared "Get" or "Do" shortcut methods
⍝        r←HttpCommand.Get 'www.dyalog.com'
⍝        r←HttpCommand.Do 'get' 'www.dyalog.com'
⍝
⍝ Constructor::
⍝   cmd←⎕NEW HttpCommand [(Command [URL [Params [Headers [Cert [SSLFlags [Priority]]]]]])]
⍝
⍝ Constructor Arguments::
⍝ All of the constructor arguments are also exposed as Public Fields
⍝   Command  - the case-insensitive HTTP command to issue
⍝              typically one of 'GET' 'POST' 'PUT' 'OPTIONS' 'DELETE' 'HEAD'
⍝   URL      - the URL to direct the command at
⍝              format is:  [HTTP[S]://][user:pass@]url[:port][/page[?params]]
⍝   Params   - the parameters to pass with the command
⍝              this can either be a URLEncoded character vector, or a namespace containing the named parameters
⍝   Headers  - any additional HTTP headers to send with the request (all the obvious headers like 'content-length' are precomputed)
⍝              a vector of 2-element (header-name value) vectors or a matrix of [;1] header-name [;2] values
⍝   Cert     - if using a SSL, this is an instance of the X509Cert class (see Conga SSL documentation)
⍝   SSLFlags - if using SSL, these are the SSL flags as described in the Conga documentation
⍝   Priority - if using SSL, this is the GNU TLS priority string (generally you won't change this from the default)
⍝
⍝ Additional Public Fields::
⍝   LocalDRC - if set, this is a reference to the DRC namespace from Conga - otherwise, we look for DRC in the workspace root\
⍝   WaitTime - time (in seconds) to wait for the response (default 30)
⍝
⍝
⍝ The methods that execute HTTP requests - Do, Get, and Run - return a namespace containing the variables:
⍝   Data          - the response message payload
⍝   HttpVer       - the server HTTP version
⍝   HttpStatus    - the response HTTP status code (200 means OK)
⍝   HttpStatusMsg - the response HTTP status message
⍝   Headers       - the response HTTP headers
⍝   PeerCert      - the server (peer) certificate if running secure
⍝   rc            - the Conga return code (0 means no error)
⍝
⍝ Public Instance Methods::
⍝
⍝   result←Run            - executes the HTTP request
⍝   name AddHeader value  - add a header value the request headers if it doesn't already exist
⍝
⍝ Public Shared Methods::
⍝
⍝   result←Get URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝
⍝   result←Do  Command URL [Params [Headers [Cert [SSLFlags [Priority]]]]]
⍝     Where the arguments are as described in the constructor parameters section.
⍝     Get and Do are shortcut methods to make it easy to execute an HTTP request on the fly.
⍝
⍝   r←Base64Decode vec     - decode a Base64 encoded string
⍝
⍝   r←Base64Encode vec     - Base64 encode a character vector
⍝
⍝   r←UrlDecode vec        - decodes a URL-encoded character vector
⍝
⍝   r←{name} UrlEncode arg - URL-encodes string(s)
⍝     name is an optional name
⍝     arg can be one of
⍝       - a character vector
⍝       - a vector of character vectors of name/value pairs
⍝       - a 2-column matrix of name/value pairs
⍝       - a namespace containing named variables
⍝     Examples:
⍝
⍝       UrlEncode 'Hello World!'
⍝ Hello%20World%21
⍝
⍝      'phrase' UrlEncode 'Hello World!'
⍝ phrase=Hello%20World%21
⍝
⍝       UrlEncode 'company' 'dyalog' 'language' 'APL'
⍝ company=dyalog&language=APL
⍝
⍝       UrlEncode 2 2⍴'company' 'dyalog' 'language' 'APL'
⍝ company=dyalog&language=APL
⍝
⍝       (ns←⎕NS '').(company language)←'dyalog' 'APL'
⍝       UrlEncode ns
⍝ company=dyalog&language=APL
⍝
⍝ Example Use Cases::
⍝
⍝ Retrieve the contents of a web page
⍝   result←HttpCommand.Get 'www.dyalog.com'
⍝
⍝ Update a record in a web service
⍝   cmd←⎕NEW HttpCommand                        ⍝ create an instance
⍝   cmd.(Command URL)←'PUT' 'www.somewhere.com' ⍝ set a couple of fields
⍝   (cmd.Params←⎕NS '').(id name)←123 'Fred'    ⍝ set the parameters for the "PUT" command
⍝   result←cmd.Run                              ⍝ and run it
⍝

    ⎕ML←⎕IO←1

    :field public Command←'GET'
    :field public Cert←⍬
    :field public SSLFlags←32
    :field public shared LocalDRC←''
    :field public URL←''
    :field public Params←''
    :field public Headers←''
    :field public Priority←'NORMAL:!CTYPE-OPENPGP'
    :field public WaitTime←30

    ∇ r←Version
      :Access public shared
      r←'HttpCommand' '1.1.0' '2017-02-26'
    ∇

    ∇ make
      :Access public
      :Implements constructor
    ∇

    ∇ make1 args
      :Access public
      :Implements constructor
      ⍝ args - [Command URL Params Headers Cert SSLFlags Priority]
      args←eis args
      Command URL Params Headers Cert SSLFlags Priority←7↑args,(⍴args)↓Command URL Params Headers Cert SSLFlags Priority
    ∇

    ∇ r←Run
      :Access public
      :If 0∊⍴Cert
          r←(Command HttpCmd)URL Params Headers
      :Else
          r←(Cert SSLFlags Priority)(Command HttpCmd)URL Params Headers
      :EndIf
    ∇

    ∇ r←Get args
    ⍝ Description::
    ⍝ Shortcut method to perform an HTTP GET request
    ⍝ args - [URL Params Headers Cert SSLFlags Priority]
      :Access public shared
      r←(⎕NEW ⎕THIS((⊂'GET'),eis args)).Run
    ∇

    ∇ r←Do args;cmd
    ⍝ Description::
    ⍝ Shortcut method to perform an HTTP request
    ⍝ args - [Command URL Params Headers Cert SSLFlags Priority]
      :Access public shared
      r←(⎕NEW ⎕THIS(eis args)).Run
    ∇


    ∇ r←{certs}(cmd HttpCmd)args;url;parms;hdrs;urlparms;p;b;secure;port;host;page;x509;flags;priority;pars;auth;req;err;chunked;chunk;buffer;chunklength;done;data;datalen;header;headerlen;status;httpver;httpstatus;httpstatusmsg;rc;dyalog;FileSep;donetime;congaCopied;peercert;formContentType;ind
⍝ issue an HTTP command
⍝ certs - optional [X509Cert [SSLValidation [Priority]]]
⍝ args  - [1] URL in format [HTTP[S]://][user:pass@]url[:port][/page]
⍝         {2} parameters is using POST - either a namespace or URL-encoded string
⍝         {3} HTTP headers in form {↑}(('hdr1' 'val1')('hdr2' 'val2'))
⍝ Makes secure connection if left arg provided or URL begins with https:
     
⍝ Result: (conga return code) (HTTP Status) (HTTP headers) (HTTP body) [PeerCert if secure]
      r←⎕NS''
      (rc httpver httpstatus httpstatusmsg header data peercert)←¯1 '' 400(⊂'bad request')(0 2⍴⊂'')''⍬
     
      args←eis args
      (url parms hdrs)←args,(⍴args)↓''(⎕NS'')''
      →0⍴⍨0∊⍴url ⍝ exit early if no URL
     
      congaCopied←0
      :If 0∊⍴LocalDRC
          :Select ⊃#.⎕NC'DRC'
          :Case 9
              LDRC←#.DRC
          :Case 0
              FileSep←'/\'[1+'Win'≡3↑1⊃#.⎕WG'APLVersion']
              dyalog←{⍵,(-FileSep=¯1↑⍵)↓FileSep}2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
              'DRC'⎕CY dyalog,'ws/conga' ⍝ runtime needs full workspace path
              :If {0::1 ⋄ 0⊣⍎'DRC'}''
                  ⎕←'Conga namespace DRC not found or defined'
                  →0
              :EndIf
              LDRC←DRC
              congaCopied←1
          :Else
              ⎕←'Conga namespace DRC not found or defined'
              →0
          :EndSelect
      :ElseIf 9=⎕NC'LocalDRC'
          LDRC←LocalDRC
      :Else
          LDRC←⍎⍕LocalDRC
      :EndIf
     
      {}LDRC.Init''
     
      url←,url
      cmd←uc,cmd
     
      (url urlparms)←{⍵{((¯1+⍵)↑⍺)(⍵↓⍺)}⍵⍳'?'}url
     
      :If 'GET'≡cmd   ⍝ if HTTP command is GET, all parameters are passed via the URL
          urlparms,←{0∊⍴⍵:⍵ ⋄ '&',⍵}UrlEncode parms
          parms←''
      :EndIf
     
      urlparms←{0∊⍴⍵:'' ⋄ ('?'=1↑⍵)↓'?',⍵}{⍵↓⍨'&'=⊃⍵}urlparms
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴,certs}(lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      (host page)←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW LDRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←'Authorization: Basic ',(Base64Encode(¯1+p←host⍳'@')↑host),NL
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      (host port)←port{(⍴⍵)<ind←⍵⍳':':⍵ ⍺ ⋄ (⍵↑⍨ind-1)(1⊃2⊃⎕VFI ind↓⍵)}host ⍝ Check for override of port number
     
      hdrs←makeHeaders hdrs
      hdrs←'User-Agent'(hdrs addHeader)'Dyalog/Conga'
      hdrs←'Accept'(hdrs addHeader)'*/*'
     
      :If ~0∊⍴parms          ⍝ if we have any parameters
          :If cmd≡'POST'     ⍝ and a POST command
              ⍝↓↓↓ specify the default content type (if not already specified)
              hdrs←'Content-Type'(hdrs addHeader)formContentType←'application/x-www-form-urlencoded'
              :If formContentType≡hdrs GetHeader'Content-Type'
                  parms←UrlEncode parms
              :EndIf
              hdrs←'Content-Length'(hdrs addHeader)⍴parms
          :EndIf
      :EndIf
     
      hdrs←'Accept-Encoding'(hdrs addHeader)'gzip, deflate'
     
      req←(uc cmd),' ',(page,urlparms),' HTTP/1.1',NL,'Host: ',host,NL
      req,←fmtHeaders hdrs
      req,←auth
     
      donetime←⌊⎕AI[3]+1000×WaitTime ⍝ time after which we'll time out
     
      :If 0=⊃(err cmd)←2↑rc←LDRC.Clt''host port'Text' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃rc←LDRC.Send cmd(req,NL,parms)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen headerlen header←0 ⍬ 0 0 ⍬
          :Repeat
              :If ~done←0≠1⊃rc←LDRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  :If rc[3]∊'Block' 'BlockLast'             ⍝ If we got some data
                      :If chunked
                          chunk←4⊃rc
                      :ElseIf 0<⍴data,←4⊃rc
                      :AndIf 0=headerlen
                          (headerlen header)←DecodeHeader data
                          :If 0<headerlen
                              data←headerlen↓data
                              :If chunked←∨/'chunked'⍷header GetHeader'Transfer-Encoding'
                                  chunk←data
                                  data←''
                              :Else
                                  datalen←⊃(toNum header GetHeader'Content-Length'),¯1 ⍝ ¯1 if no content length not specified
                              :EndIf
                          :EndIf
                      :EndIf
                  :Else
                      ⎕←rc ⍝ Error?
                      ∘∘∘  ⍝ !! Intentional !!
                  :EndIf
                  :If chunked
                      buffer,←chunk
                      :While done<¯1≠⊃(len chunklength)←getchunklen buffer
                          :If (⍴buffer)≥4+len+chunklength
                              data,←chunklength↑(len+2)↓buffer
                              buffer←(chunklength+len+4)↓buffer
                              :If done←0=chunklength ⍝ chunked transfer can add headers at the end of the transmission
                                  header←header⍪2⊃DecodeHeader buffer
                              :EndIf
                          :EndIf
                      :EndWhile
                  :Else
                      done←done∨'BlockLast'≡3⊃rc                        ⍝ Done if socket was closed
                      :If datalen>0
                          done←done∨datalen≤⍴data ⍝ ... or if declared amount of data rcvd
                      :Else
                          done←done∨(∨/'</html>'⍷data)∨(∨/'</HTML>'⍷data)
                      :EndIf
                  :EndIf
              :ElseIf 100=1⊃rc ⍝ timeout?
                  done←⎕AI[3]>donetime
              :EndIf
          :Until done
     
          :If 0=1⊃rc
              :Trap 0 ⍝ If any errors occur, abandon conversion
                  :Select header GetHeader'content-encoding' ⍝ was the response compressed?
                  :Case 'deflate'
                      data←fromutf8 LDRC.flate.Inflate 120 156{(2×⍺≡2↑⍵)↓⍺,⍵}256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
                  :Case 'gzip'
                      data←fromutf8 256|¯3(219⌶)83 ⎕DR data
                  :Else
                      :If ∨/'charset=utf-8'⍷header GetHeader'content-type'
                          data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
                      :EndIf
                  :EndSelect
     
                  :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
                      →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}header ⍝ use the "location" header field for the URL
                  :EndIf
     
              :EndTrap
     
              httpver httpstatus httpstatusmsg←{⎕ML←3 ⋄ ⍵⊂⍨{⍵∨2<+\~⍵}⍵≠' '}(⊂1 1)⊃header
              header↓⍨←1
     
              :If secure ⋄ peercert←⊂LDRC.GetProp cmd'PeerCert' ⋄ :EndIf
          :EndIf
     
          r.(rc httpver httpstatus httpstatusmsg headers data peercert)←(1⊃rc)httpver(toNum httpstatus)httpstatusmsg header data peercert
     
      :Else
          ⎕←'Connection failed ',,⍕rc
          r.rc←1⊃rc
      :EndIf
     
      {}LDRC.Close cmd
     
      :If congaCopied
          {}LDRC.Close'.'
          LDRC.(⎕EX¨⍙naedfns)
      :EndIf
    ∇

    NL←⎕UCS 13 10
    fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
    utf8←{3=10|⎕DR ⍵: 256|⍵ ⋄ 'UTF-8' ⎕UCS ⍵}
    sint←{⎕io←0 ⋄ 83=⎕DR ⍵:⍵ ⋄ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 ¯128 ¯127 ¯126 ¯125 ¯124 ¯123 ¯122 ¯121 ¯120 ¯119 ¯118 ¯117 ¯116 ¯115 ¯114 ¯113 ¯112 ¯111 ¯110 ¯109 ¯108 ¯107 ¯106 ¯105 ¯104 ¯103 ¯102 ¯101 ¯100 ¯99 ¯98 ¯97 ¯96 ¯95 ¯94 ¯93 ¯92 ¯91 ¯90 ¯89 ¯88 ¯87 ¯86 ¯85 ¯84 ¯83 ¯82 ¯81 ¯80 ¯79 ¯78 ¯77 ¯76 ¯75 ¯74 ¯73 ¯72 ¯71 ¯70 ¯69 ¯68 ¯67 ¯66 ¯65 ¯64 ¯63 ¯62 ¯61 ¯60 ¯59 ¯58 ¯57 ¯56 ¯55 ¯54 ¯53 ¯52 ¯51 ¯50 ¯49 ¯48 ¯47 ¯46 ¯45 ¯44 ¯43 ¯42 ¯41 ¯40 ¯39 ¯38 ¯37 ¯36 ¯35 ¯34 ¯33 ¯32 ¯31 ¯30 ¯29 ¯28 ¯27 ¯26 ¯25 ¯24 ¯23 ¯22 ¯21 ¯20 ¯19 ¯18 ¯17 ¯16 ¯15 ¯14 ¯13 ¯12 ¯11 ¯10 ¯9 ¯8 ¯7 ¯6 ¯5 ¯4 ¯3 ¯2 ¯1[utf8 ⍵]}
    lc←(819⌶) ⍝ lower case conversion
    uc←1∘lc
    dlb←{(+/∧\' '=⍵)↓⍵} ⍝ delete leading blanks
    split←{(p↑⍵)((p←¯1+⍵⍳⍺)↓⍵)} ⍝ split ⍵ on first occurrence of ⍺
    h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳lc ⍵} ⍝ hex to decimal
    getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
    toNum←{0∊⍴⍵:⍬ ⋄ 1⊃2⊃⎕VFI ⍕⍵}
    makeHeaders←{0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵}
    fmtHeaders←{0∊⍴⍵:'' ⋄ ∊{0∊⍴2⊃⍵:'' ⋄ NL,⍨(firstCaps 1⊃⍵),': ',⍕2⊃⍵}¨↓⍵}
    firstCaps←{1↓{(¯1↓0,'-'=⍵) (819⌶)¨ ⍵}'-',⍵}
    addHeader←{'∘???∘'≡⍺⍺ GetHeader ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺} ⍝ add a header unless it's already defined

    ∇ name AddHeader value
    ⍝ add a header unless it's already defined
      :Access public
      Headers←makeHeaders Headers
      Headers←name(Headers addHeader)value
    ∇

    ∇ r←a GetHeader w
      :Access public shared
      r←a{(⍺[;2],⊂'∘???∘')⊃⍨(lc¨⍺[;1])⍳eis lc ⍵}w
    ∇

    ∇ r←{a}eis w;f
    ⍝ enclose if simple
      :Access public shared
      f←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵}
      :If 0=⎕NC'a' ⋄ r←f w
      :Else ⋄ r←a f w
      :EndIf
    ∇

    ∇ r←Base64Encode w
    ⍝ Base64 Encode
      :Access public shared
      r←{⎕IO←0
          raw←⊃,/11∘⎕DR¨⍵
          cols←6
          rows←⌈(⊃⍴raw)÷cols
          mat←rows cols⍴(rows×cols)↑raw
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'[⎕IO+2⊥⍉mat],(4|-rows)⍴'='}w
    ∇

    ∇ r←Base64Decode w
    ⍝ Base64 Encode
      :Access public shared
      r←{
          ⎕IO←0
          {
              80=⎕DR' ':⎕UCS ⍵  ⍝ Unicode
              82 ⎕DR ⍵          ⍝ Classic
          }2⊥{⍉((⌊(⍴⍵)÷8),8)⍴⍵}(-6×'='+.=⍵)↓,⍉(6⍴2)⊤'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='{⍺⍳⍵∩⍺}⍵
      }w
    ∇

    ∇ r←DecodeHeader buf;len;d;i
      ⍝ Decode HTTP Header
      r←0(0 2⍴⊂'')
      :If 0<i←⊃{((NL,NL)⍷⍵)/⍳⍴⍵}buf
          len←(¯1+⍴NL,NL)+i
          d←(⍴NL)↓¨{(NL⍷⍵)⊂⍵}NL,len↑buf
          d←↑{((p-1)↑⍵)((p←⍵⍳':')↓⍵)}¨d
          d[;1]←lc¨d[;1]
          d[;2]←dlb¨d[;2]
          r←len d
      :EndIf
    ∇

    ∇ r←{name}UrlEncode data;⎕IO;z;ok;nul;m;noname
      ⍝ data is one of:
      ⍝      - a character vector to be encoded
      ⍝      - two character vectors of [name] [data to be encoded]
      ⍝      - a namespace containing variable(s) to be encoded
      ⍝ name is the optional name
      ⍝ r    is a character vector of the URLEncoded data
     
      :Access Public Shared
      ⎕IO←0
      noname←0
      :If 9.1=⎕NC⊂'data'
          data←{0∊⍴t←⍵.⎕NL ¯2:'' ⋄ ↑⍵{⍵(⍕,⍺⍎⍵)}¨t}data
      :Else
          :If 1≥|≡data
              :If noname←0=⎕NC'name' ⋄ name←'' ⋄ :EndIf
              data←name data
          :EndIf
      :EndIf
      nul←⎕UCS 0
      ok←nul,∊⎕UCS¨(⎕UCS'aA0')+⍳¨26 26 10
     
      z←⎕UCS'UTF-8'⎕UCS∊nul,¨,data
      :If ∨/m←~z∊ok
          (m/z)←↓'%',(⎕D,⎕A)[⍉16 16⊤⎕UCS m/z]
          data←(⍴data)⍴1↓¨{(⍵=nul)⊂⍵}∊z
      :EndIf
     
      r←noname↓¯1↓∊data,¨(⍴data)⍴'=&'
    ∇

    ∇ r←UrlDecode r;rgx;rgxu;i;j;z;t;m;⎕IO;lens;fill
      :Access public shared
      ⎕IO←0
      ((r='+')/r)←' '
      rgx←'[0-9a-fA-F]'
      rgxu←'%[uU]',(4×⍴rgx)⍴rgx ⍝ 4 characters
      r←(rgxu ⎕R{{⎕UCS 16⊥⍉16|'0123456789ABCDEF0123456789abcdef'⍳⍵}2↓⍵.Match})r
      :If 0≠⍴i←(r='%')/⍳⍴r
      :AndIf 0≠⍴i←(i≤¯2+⍴r)/i
          z←r[j←i∘.+1 2]
          t←'UTF-8'⎕UCS 16⊥⍉16|'0123456789ABCDEF0123456789abcdef'⍳z
          lens←⊃∘⍴¨'UTF-8'∘⎕UCS¨t  ⍝ UTF-8 is variable length encoding
          fill←i[¯1↓+\0,lens]
          r[fill]←t
          m←(⍴r)⍴1 ⋄ m[(,j),i~fill]←0
          r←m/r
      :EndIf
    ∇

    ∇ r←Documentation;sections;box;⎕IO;CR
      :Access public shared
      ⎕IO←1
      CR←⎕UCS 13
      box←{{⍵{⎕AV[(1,⍵,1)/223 226 222],CR,⎕AV[231],⍺,⎕AV[231],CR,⎕AV[(1,⍵,1)/224 226 221]}⍴⍵}(⍵~CR),' '}
      r←1↓⎕SRC ⎕THIS
      r←1↓¨r/⍨∧\'⍝'=⊃¨r ⍝ keep all contiguous comments
      r←r/⍨'⍝'≠⊃¨r     ⍝ remove any lines beginning with ⍝⍝
      sections←{∨/'::'⍷⍵}¨r
      (sections/r)←box¨sections/r
      r←∊r,¨CR
    ∇

    ∇ r←Describe;sections;box;⎕IO;CR
      :Access public shared
      ⎕IO←1
      CR←⎕UCS 13
      box←{{⍵{⎕AV[(1,⍵,1)/223 226 222],CR,⎕AV[231],⍺,⎕AV[231],CR,⎕AV[(1,⍵,1)/224 226 221]}⍴⍵}(⍵~CR),' '}
      r←1↓⎕SRC ⎕THIS
      r←1↓¨r/⍨∧\'⍝'=⊃¨r ⍝ keep all contiguous comments
      r←r/⍨'⍝'≠⊃¨r     ⍝ remove any lines beginning with ⍝⍝
      sections←{∨/'::'⍷⍵}¨r
      (sections r)←((2>+\sections)∘/¨sections r)
      (sections/r)←box¨sections/r
      r←∊r,¨CR
    ∇

:EndClass
