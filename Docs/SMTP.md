# SMTP - a class to send emails using SMTP #
## Overview ##
SMTP is a class which implements a client interface that allows you to send emails via an SMTP server.

First define the server:

```APL
client←SMTP.NewClient ''
client.Server←'mail.somecompany.com'
client.From←'somebody@company.com'
client.Password←'secret'
```

Now define and send a message

```APL
msg←client.NewMessage ''
msg.Subject←'The subject of the message'
msg.Body←'This is the body of the message'
msg.To←'someoneelse@someothercompany.com'
msg.Send
```
## Dependencies ##
* SMTP uses Conga for TCP/IP communications. If 
## Client Reference ##
### Client Shared Methods ###
```APL
      ref←SMTP.NewClient args
```
<table><tr valign="top">
<td><code>ref</code></td>
<td>reference to the newly created client</td></tr>
<tr  valign="top">
<td><code>args</code></td>
<td>either a vector of up to 7 properties or a reference to a namespace containing named properties
<table>
<thead valign="bottom"><th>Vector Position or Namespace Variable</th><th>Description</th><th>Example(s)</th></thead>
<tr valign="top"><td><code><b>[1] Server<code></b></td><td>Server URI</td><td><code>'mail.somecompany.com'</code></td></tr>
<tr valign="top">
<td><code>[2] Port<code></td><td>Server Port</br>Default is 465 if Secure is set to 1, 587 otherwise</td>
<td><pre><code>⍬   ⍝ use default</br>929 ⍝ custom port</code></pre></td></tr>
<tr valign="top"><td><code><b>[3] From<code><b></td><td>"From" email address. Also used as <code>Userid</code> if <code>Userid</code> is not specified</td><td><code>'someone@somewhere.com'</code></td></tr>
<tr valign="top"><td><code>[4] Password<code></td><td>SMTP server password</td><td><code>'somethingsecret'</code></td></tr>
<tr valign="top"><td><code>[5] Userid<code></td><td>SMTP server userid, if different from <code>From</code></td><td><code>'' ⍝ use From</br>'myuserid@somewhere.com' </code></td></tr>
<tr valign="top"><td><code>[6] ReplyTo<code></td><td>ReplyTo address if different than <code>From</code></td><td><code>'replytome@somecompany.com'</code></td></tr>
<tr valign="top"><td><code>[7] Secure</code></td><td>1 if running secure using SSL, 0 otherwise.  Default is ¯1 which means the client will determine based on the port being used.</td><td><code>1 ⍝ secure</br>0 ⍝ not secure</code></td></tr>
</table></td></tr>
</table> 

**Usage Notes:**

* `Server` and `From` are required. `Password` may be required if your SMTP server requires authentication.
* If you know the port for your SMTP server, it's best to set `Port` explicitly. Otherwise, `Port` will be set to 465 if `Secure` is set to 1 and 587 otherwise.  If `Secure` is not specified it will be set to 1 if `Port` is 465 and 0 otherwise.
* If `Userid` is not specified, `From` will be used as the userid for login purposes.

**Examples**

```
      client←NewClient 'mail.company.com' ⍬ 'me@company.com'
```

----
          (name version date)←SMTP.Version
          SMTP.Version
    ┌────┬───┬──────────┐
    │SMTP│1.3│2021-03-02│
    └────┴───┴──────────┘



### Client Instance Methods ###
### Client Shared Fields ###
### Client Instance Fields ###
These are the public methods exposed in the SMTP class.
## Installation ##

