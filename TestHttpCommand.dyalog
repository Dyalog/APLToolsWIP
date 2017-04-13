:Namespace TestHttpCommand
    (⎕IO ⎕ML)←1 1

    _TestData←⎕NS ''
    _TestData.(number charvec)←23 'HttpCommand test'
    _TestUrl←'httpbin.org'

    _AplVersion←2⊃⎕VFI{⍵/⍨∧\⍵≠'.'}2⊃#.⎕WG'APLVersion'
    fromJSON←{16≤_AplVersion:⎕JSON ⍵ ⋄ (7159⌶)⍵}
    aplName←{0(7162⌶)⍵}  ⍝ JSON → APL name
    jsonName←{1(7162⌶)⍵} ⍝ APL → JSON name
    report←{⍵⊣⎕←(50↑⍺),(': Failed' ': Passed'[1+⍵])}
    _true←⊂'true'

    :section Tests

    ∇ {r}←TestAll;tests;test
      tests←(⊂'TestAll')~⍨tests/⍨{'Test'≡4↑⍵}¨tests←⎕NL ¯3
      r←⍬
      :For test :In tests
          r,←~⍎test
      :EndFor
      r←r/tests
    ∇

    ∇ {r}←TestGet
      r←'HTTP GET basic'report 0 200≡(#.HttpCommand.Get _TestUrl,'/get').(rc HttpStatus)
    ∇

    ∇ {r}←TestDeflate;result
      r←0
      result←#.HttpCommand.Get _TestUrl,'/deflate'
      :Trap 0
          r←(0 200,_true,(⊂'deflate'))≡result.(rc HttpStatus),((fromJSON result.Data).deflated),⊂result.Headers #.HttpCommand.Lookup'content-encoding'
      :EndTrap
      r←'Deflate'report r
    ∇

    ∇ {r}←TestGzip;result
      r←0
      result←#.HttpCommand.Get _TestUrl,'/gzip'
      :Trap 0
          r←(0 200,_true,(⊂'gzip'))≡result.(rc HttpStatus),((fromJSON result.Data).gzipped),⊂result.Headers #.HttpCommand.Lookup'content-encoding'
      :EndTrap
      r←'Gzip'report r
    ∇

    ∇ {r}←TestChunked;result
      result←#.HttpCommand.Get'https://www.httpwatch.com/httpgallery/chunked/chunkedimage.aspx'
      r←'HTTP GET chunked'report 0 200 'chunked'≡result.(rc HttpStatus(Headers #.HttpCommand.Lookup'transfer-encoding'))
    ∇

    ∇ {r}←TestRestfulGet;host
      :Access public shared
      host←'https://jsonplaceholder.typicode.com/'
      r←'RESTful GET all posts'report 0 200∧.=(#.HttpCommand.Get host,'posts').(rc HttpStatus)
    ∇

    ∇ {r}←TestRestfulPost;host;params
      :Access public shared
      host←'https://jsonplaceholder.typicode.com/'
      (params←⎕NS'').(title body userId)←'foo' 'bar' 1
      r←'RESTful POST'report 0 201∧.=(#.HttpCommand.Do'post'(host,'posts')params).(rc HttpStatus)
    ∇

    ∇ {r}←TestRestfulPut;host;params
      :Access public shared
      host←'https://jsonplaceholder.typicode.com/'
      (params←⎕NS'').(title body userId id)←'foo' 'bar' 1 200
      r←'RESTful PUT'report 0 200∧.=(#.HttpCommand.Do'put'(host,'posts/1')params).(rc HttpStatus)
    ∇

    :endsection

:EndNamespace
