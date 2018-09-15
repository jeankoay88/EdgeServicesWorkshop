---


---

<h1 id="edge-services-workshop">Edge Services Workshop</h1>
<p><strong>WebGoat</strong> is a deliberately insecure web application maintained by <a href="http://www.owasp.org">OWASP</a> designed to teach web application security lessons. Users must demonstrate their understanding of a security issue by exploiting a real vulnerability in the WebGoat applications. For example, in one of the lessons the user must use <a href="https://www.owasp.org/index.php/SQL_injection" title="SQL injection">SQL injection</a> to steal fake credit card numbers. The application aims to provide a realistic teaching environment, providing users with hints and code to further explain the lesson.</p>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/WebGoat.png" alt="enter image description here"></p>
<p><strong>What are the characteristics of the web application (details for Cloudfront CDN and WAF configuration)?</strong></p>
<ol>
<li>
<p>It serves static assets (.jpg, .css, .js) directly from the virtual machine (AWS Load Balancer).</p>
</li>
<li>
<p>To maintain an existing session, it relies on the JSESSIONID cookie.</p>
</li>
<li>
<p>It relies on query strings to fetch content to render webpage.</p>
</li>
<li>
<p>It has a list of security vulnerabilities that can be exploited.</p>
</li>
</ol>
<p><strong>What is the goal of this lab?</strong></p>
<ol>
<li>
<p><em>Accelerate Static Content Delivery</em> for better user experience – Static content will be cached and delivered nearer to end users with Cloudfront Point of Presence</p>
</li>
<li>
<p><em>Accelerate Dynamic Content Deliver</em> for better user experience – Dynamic Content will be delivered nearer to end users and accelerated with TCP optimizations.</p>
</li>
<li>
<p><em>Protect and Mitigate Web App Security Risk</em> – AWS WAF deployed with AWS Cloudfront will proactively block attacks based on Top 10 OWASP Web Vulnerabilities rules eg. SQL Injection, XSS scripting.</p>
</li>
</ol>
<p><strong>What building blocks are involved in this lab?</strong></p>
<ol>
<li>
<p><em>Cloudfront - Serving Content over the Edge</em><br>
AWS Cloudfront is a web service that speeds up distribution of your static and dynamic web content, such as .html, .css, .js, and image files, to your users. CloudFront delivers your content through a worldwide network of data centers called edge locations.</p>
</li>
<li>
<p><em>Web Application Firewall (AWS WAF) – Perimeter Protection</em><br>
AWS WAF is a web application firewall that helps protect your web applications from common web exploits that could affect application availability, compromise security, or consume excessive resources. AWS WAF gives you control over which traffic to allow or block to your web applications by defining customizable web security rules.</p>
</li>
<li>
<p><em>Elastic Application Load Balancer (AWS ALB)</em><br>
A <em>load balancer</em> serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones. This increases the availability of your application.</p>
</li>
<li>
<p><em>Elastic Cloud Compute (AWS EC2)</em><br>
Amazon Elastic Compute Cloud (Amazon EC2) is a web service that provides resizable compute capacity in the cloud. Think of running virtual machines in the Cloud on-demand.</p>
</li>
</ol>
<h2 id="table-of-contents">Table of Contents</h2>
<ul>
<li>
<p><a href="#create-vpc-environment">Create the VPC Environment</a></p>
</li>
<li>
<p><a href="#create-the-webapp-environment">Create the WebApp Environment</a></p>
</li>
<li>
<p><a href="#create-an-edge-to-accelerate-and-protect-your-web-app">Create your Edge to Accelerate and Protect your Web App</a></p>
</li>
<li>
<p><a href="#test-original-webapp-behaviour">Test Original Website Behaviour</a></p>
</li>
<li>
<p><a href="#how-cloudfront-improves-performance-and-waf-secures-your-environment">How Cloudfront improves performance and WAF secures your environment </a></p>
</li>
</ul>
<h1 id="create-vpc-environment">Create VPC Environment</h1>
<ol>
<li>
<p>Load <a href="https://ap-southeast-1.console.aws.amazon.com/cloudformation/home?region=ap-southeast-1#/stacks/new?stackName=Quick-Start-VPC&amp;templateURL=https://aws-quickstart.s3.amazonaws.com/quickstart-aws-vpc/templates/aws-vpc.template">VPC Quick Start</a> Cloudformation Template on AWS Web Console</p>
</li>
<li>
<p>Configure VPC Cloudformation Template</p>
<blockquote>
<p><strong>Parameters:</strong><br>
Availability Zones: <code>ap-southeast-1a</code> &amp; <code>ap-southeast-1b</code><br>
Number of Availability Zones : 2<br>
KeyPair : <code>&lt;put in valid key pair&gt;</code></p>
</blockquote>
</li>
<li>
<p>Once complete, go to Cloudformation “output”, note down the :</p>
<ul>
<li>VPCID</li>
<li>PrivateSubnet1AID</li>
<li>PublicSubnet1ID</li>
<li>PublicSubnet2ID<br>
<img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/CloudFormationOutput.png" alt="CloudFormation Output"></li>
</ul>
</li>
</ol>
<h1 id="create-the-webapp-environment">Create the Webapp Environment</h1>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/WebGoat.png" alt="CloudFormation Output"></p>
<p><strong>Instructions how to build webapp environment</strong></p>
<ol>
<li>
<p>At your computer, download the <a href="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/webapp-launch.sh">bash script</a> &amp; save as <code>webapp-launch.sh</code></p>
</li>
<li>
<p>Replace the ‘bracketed section’ of the bash script with the values that you obtained from the cloudformation output (in previous section), i.e.  <code>VPCID</code>, <code>PrivateSubnet1AID</code>, <code>PublicSubnet1ID</code>, and <code>PublicSubnet2ID</code></p>
</li>
<li>
<p>Run <code>chmod +x webapp-launch.sh</code>.</p>
</li>
<li>
<p>Run it as bash <code>./webapp-launch.sh &lt;keypair-name&gt;</code></p>
</li>
</ol>
<h1 id="create-an-edge-to-accelerate-and-protect-your-web-app">Create an Edge to Accelerate and Protect your Web App</h1>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/CreateAnEdge.png" alt="enter image description here"></p>
<h3 id="create-the-owasp-waf-acl">Create the OWASP WAF ACL</h3>
<ol>
<li>
<p>Go to <a href="https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-1#/stacks/new?stackName=AWSWAFSecurityAutomations&amp;templateURL=https:%2F%2Fs3.amazonaws.com%2Fsolutions-reference%2Faws-waf-security-automations%2Flatest%2Faws-waf-security-automations.template">AWS Console &gt; CloudFormation (Region: Singapore)</a></p>
</li>
<li>
<p>Name your WAF Stack as <code>&lt;name&gt;waf</code>. For an example “fabiantanwaf”.</p>
</li>
<li>
<p>Fill up Cloudfront Access Log Bucket Name.</p>
<blockquote>
<p>Create a new S3 bucket for this. WAF deployment will fail should it has certain config associated to it.</p>
</blockquote>
</li>
<li>
<p>Click “Next” and “Next”.</p>
</li>
<li>
<p>Finally, at the bottom of the page, click “<em>I acknowledge that AWS CloudFormation might create IAM resources.</em>” and click “Create”</p>
</li>
</ol>
<h3 id="create-cloudfront-distribution--edit-behaviour">Create Cloudfront Distribution &amp; Edit Behaviour</h3>
<ol>
<li>
<p>Go to <a href="https://console.aws.amazon.com/cloudfront/home">AWS Console</a> top banner &gt; Services &gt; CloudFront</p>
</li>
<li>
<p>Click on the <strong>Create Distribution</strong> button to begin</p>
</li>
<li>
<p>Select <strong>Get Started</strong> on the Web Distribution</p>
</li>
<li>
<p>In “Origin Settings”, Fill <strong>“Origin Domain Name”</strong> with your Application Load balancer endpoint launched by bash script e.g. <strong>"<a href="http://fabiantan2-ALB-141106376.ap-southeast-1.elb.amazonaws.com">fabiantan2-ALB-141106376.ap-southeast-1.elb.amazonaws.com</a>"</strong></p>
</li>
<li>
<p>Leave “Origin Path” empty</p>
</li>
<li>
<p>In “Default Cache Behaviour Settings”, select <strong>Allowed HTTP Method</strong> “GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE”.</p>
</li>
<li>
<p>In “Default Cache Behaviour Settings”, select <strong>Cache Based on Selected Request Headers</strong> -&gt;“Whitelist”-&gt; Select “Host”-&gt; Add.</p>
</li>
<li>
<p>In “Default Cache Behaviour Settings”, set “Object Caching” to Customize. Configure “Minimum/Maximum/Default TTL” to 0</p>
</li>
<li>
<p>In “Default Cache Behaviour Settings”, Set Forward cookies=Whitelist, Whitelist Cookies= JSESSIONID</p>
</li>
<li>
<p>In “Default Cache Behaviour Settings”, Set Query String Forward and Caching = “Forward all, cache based on all”</p>
</li>
<li>
<p>In “Distribution Setting”, Select <strong>Price Class</strong> as “US, Canada, Europe, Asia and Africa”</p>
</li>
<li>
<p>In “Distribution Setting”, Select <strong>AWS WAF Web ACL</strong> as “fabiantanwaf” &lt;- this would be the WAF ACL you’ve created earlier.</p>
</li>
<li>
<p>Once completed, go to the bottom right to click “Create Distribution”</p>
</li>
<li>
<p>Go to <a href="https://console.aws.amazon.com/cloudfront/home">AWS Console</a></p>
</li>
<li>
<p>Click on the distribution you’ve just created and select “Distribution Settings”</p>
</li>
<li>
<p>Select “Behaviours” tab.</p>
</li>
<li>
<p>Create a specific behaviour for</p>
<p>i) Images:</p>
<pre><code>a) Click "Create Behaviour".
b) Fill "Path Pattern" with "*.jpg"
c) Select Customized for "Object Caching". Minimum TTL=0, Maximum TTL=31536000, Default TTL=86400
d) Forward Cookies -&gt; Whitelist-&gt; JSESSIONID
e) Click Create Behaviour
</code></pre>
<p>ii) Javascript:</p>
<pre><code>a) Click "Create Behaviour".
b) Fill "Path Pattern" with "*.js"
c) Select Customized for "Object Caching". Minimum TTL=0, Maximum TTL=31536000, Default TTL=86400
d) Forward Cookies -&gt; Whitelist-&gt; JSESSIONID
e) Compress Object Automatically - YES
f) Click Create Behaviour
</code></pre>
<p>ii) CSS:</p>
<pre><code>a) Click "Create Behaviour".
b) Fill "Path Pattern" with "*.css"
c) Select Customized for "Object Caching". Minimum TTL=0, Maximum TTL=31536000, Default TTL=86400
d) Forward Cookies -&gt; Whitelist-&gt; JSESSIONID
e) Compress Object Automatically - YES
e) Click Create Behaviour
</code></pre>
</li>
</ol>
<blockquote>
<p><strong>NOTE:</strong> <em>Please move on to next section -  AWS Cloudfront distribution will take 10 minutes to propagate changes</em></p>
</blockquote>
<h1 id="test-original-website-behaviour">Test Original Website Behaviour</h1>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/TestOriginal.png" alt="enter image description here"></p>
<blockquote>
<p><strong>Note:</strong> Test will take place directly against Load Balancer Endpoint – eg. <a href="http://fabiantan2-ALB-141106376.ap-southeast-1.elb.amazonaws.com">fabiantan2-ALB-141106376.ap-southeast-1.elb.amazonaws.com</a></p>
<p><strong>Note:</strong> Load Balancer <em>does not offer any Network Layer 7 protection.</em></p>
</blockquote>
<ol>
<li>
<p>Go to <a href="%5Bhttps://ap-southeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-southeast-1#LoadBalancers:sort=loadBalancerName%5D(https://ap-southeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-southeast-1#LoadBalancers:sort=loadBalancerName)">AWS Console &gt; Load Balancer (Region: Singapore)</a></p>
</li>
<li>
<p>Select Load Balancer with your Name e.g. fabiantan on the search bar on the web console</p>
</li>
<li>
<p>Copy the DNS Name e.g. <a href="http://fabiantan2-ALB-141106376.ap-southeast-1.elb.amazonaws.com">fabiantan2-ALB-141106376.ap-southeast-1.elb.amazonaws.com</a><br>
<img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/ELB-DNS.png" alt="enter image description here"></p>
</li>
<li>
<p>On your Google Chrome, enter url <code>http://&lt;alb endpoint&gt;.ap-southeast-1.elb.amazonaws.com/WebGoat</code></p>
</li>
<li>
<p>On Google Chrome, open up “View-&gt;Developer-&gt;Developer Tools” or <kbd>cmd+opt+i </kbd>. Option: if using Firefox, then it will be <kbd>ctrl+shift+j </kbd> or <kbd>cmd+shift+j </kbd> (Mac)</p>
</li>
<li>
<p>On your “Developer Tools”, select “Network”</p>
</li>
<li>
<p>Enter username:<code>guest</code>, password: <code>guest</code> to log in on WebGoat login page<br>
<img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/username-snap.png" alt="enter image description here"></p>
</li>
<li>
<p>On the left-hand side, select <strong>“Injection Flaws”</strong> and then select “String SQL Injection”</p>
<p>i) Read description - Fill up the “Enter your last name:” with “Smith”. Observe that you’re getting a success “200” response on Chrome Developer Tool</p>
<p>ii) Now for the attack on the Database! Fill up the “Enter your last name:” with <code>Smith' or 'x'='x</code>.</p>
<blockquote>
<p>Observe that you’ve successfully executed a SQL Injection on the vulnerable website, and that the website has listed down everyone’s details on the website.</p>
</blockquote>
</li>
<li>
<p>On the left hand side, select <strong>“Cross Site Scripting (XSS)”</strong> and then select “Stored XSS Attack”</p>
<p>i) Read description - Fill up the “Title:” with “Saying Hello!”, “Message:” with “Just wanted to say hi - since I’m new here”.  Observe that you’re getting a success “200” response.</p>
<p>ii) Now, for the attack on the Database! Fill up the “Title:” with “Saying Hello Again!”, “Message:” with <code>Just wanted to say hi - since I'm new here&lt;script language="javascript" type="text/javascript"&gt;alert("Uploading a malicious script into the forum. Hopefully I can capture some sensitive data");&lt;/script&gt;</code>.</p>
<blockquote>
<p>Observe that you’ve successfully executed a XSS attack on the vulnerable website. And that the website has stored a javascript that will be executed for anyone that opens the page.</p>
</blockquote>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/Attacked.png" alt="enter image description here"></p>
</li>
<li>
<p>On the left hand side, select <strong>“Cross Site Scripting (XSS)”</strong> and then select “Reflected XSS Attack”</p>
<p>i) Fill up the “Enter your three digit access code:” with <code>111&lt;script&gt; var test = "username=John Smith; expires=Thu, 18 Dec 2013 12:00:00 UTC; path=/";alert(test)&lt;/script&gt;</code></p>
<blockquote>
<p>Observe that you’ve successfully executed a XSS attack on the vulnerable website.</p>
</blockquote>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/ShoppingCart.png" alt="enter image description here"></p>
</li>
</ol>
<p>******** <strong>Can we mitigate these attacks with AWS WAF perimeter protection?</strong>  ******</p>
<hr>
<h1 id="how-cloudfront-improves-performance-and-waf-secures-your-environment">How Cloudfront improves performance and WAF secures your environment</h1>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/ContentsWAFOverview.png" alt="enter image description here"></p>
<h3 id="serving-content-via-aws-cloudfront-and-having-aws-waf-securing-your-environment">Serving Content via AWS Cloudfront and Having AWS WAF Securing your Environment</h3>
<p><strong>Static Content Cached</strong></p>
<p>Run the following at your terminal:</p>
<pre><code>curl -kI http://&lt;cloudfront distribution endpoint&gt;/WebGoat/css/img/logoBG.jpg
curl -kI http://&lt;cloudfront distribution endpoint&gt;/WebGoat/css/main.css
curl -kI http://&lt;cloudfront distribution endpoint&gt;/WebGoat/js/main.js
</code></pre>
<p><strong><em>How do you know if your static content is cached?</em></strong></p>
<blockquote>
<p>Example:</p>
</blockquote>
<pre><code>curl -kI http://d2vlggwak7sn2j.cloudfront.net/WebGoat/css/main.css
HTTP/1.1 200 OK
Content-Type: text/css
Content-Length: 19986
Connection: keep-alive
Date: Mon, 10 Sep 2018 08:08:33 GMT
Server: Apache-Coyote/1.1
Accept-Ranges: bytes
ETag: W/"19986-1479487864000"
Last-Modified: Fri, 18 Nov 2016 16:51:04 GMT
Vary: Accept-Encoding
Age: 975
X-Cache: Hit from cloudfront
Via: 1.1 934dd0fb722aa582f1b4a3cdae35b12d.cloudfront.net (CloudFront)
X-Amz-Cf-Id: ZwCHqp0fV5A3y5HNKvqpcqDM6DX_uNTnUI9foPmmnKmx2bKVMqtM9g==
</code></pre>
<blockquote>
<p><strong>NOTE:</strong> In order to get the cache hit, you need to repeat the url hitting at least two times. Usually first time is seeding the cache, so you will get cache miss. Second time onwards hitting will get the cache hit</p>
</blockquote>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/cachehit-cachemiss.png" alt="enter image description here"></p>
<p><strong>With AWS Cloudfront, is your entire webapp delivered via AWS Cloudfront?</strong></p>
<ol>
<li>
<p>Go to <a href="%5Bhttps://console.aws.amazon.com/cloudfront/home%5D(https://console.aws.amazon.com/cloudfront/home)">AWS Console</a></p>
</li>
<li>
<p>Select Cloudfront distribution with your Name e.g. fabiantan on the search bar on the web console</p>
</li>
<li>
<p>Copy the DNS Name of Cloudfront e.g. <code>d2vlggwak7sn2j.cloudfront.net</code></p>
</li>
<li>
<p>On your Google Chrome, Open <code>http://&lt;cloudfront endpoint&gt;/WebGoat</code></p>
</li>
<li>
<p>On Google Chrome, open up “View-&gt;Developer-&gt;Developer Tools” .</p>
</li>
<li>
<p>On your “Developer Tools”, select “Network”</p>
</li>
<li>
<p>Enter username:<code>guest</code>, password: <code>guest</code> to log in to WebGoat webApp</p>
</li>
<li>
<p>On the left-hand side, select <strong>“Injection Flaws”</strong> and then select “String SQL Injection”</p>
<p>i) Read description - Fill up the “Enter your last name:” with “Smith”. Observe that you’re getting a success “200” response on Chrome Developer Tool</p>
<p>ii) Now for the attack on the Database! Fill up the “Enter your last name:” with “Smith’ or ‘x’='x”.</p>
<blockquote>
<p>Observe that your SQL Injection on the vulnerable website has been blocked with Chrome Developer Tool</p>
</blockquote>
</li>
<li>
<p>On the left hand side, select <strong>“Cross Site Scripting (XSS)”</strong> and then select “Stored XSS Attack”</p>
<p>i) Read description - Fill up the “Title:” with “Saying Hello!”, “Message:” with “Just wanted to say hi - since I’m new here”.  Observe that you’re getting a success “200” response.</p>
<p>ii) Now, for the attack on the Database! Fill up the “Title:” with “Saying Hello Again!”, “Message:” with <code>Just wanted to say hi - since I'm new here&lt;script language="javascript" type="text/javascript"&gt;alert("Uploading a malicious script into the forum. Hopefully I can capture some sensitive data");&lt;/script&gt;.</code></p>
<blockquote>
<p>Observe that your XSS attack on the vulnerable website has been blocked with Chrome Developer Tool</p>
</blockquote>
</li>
<li>
<p>On the left hand side, select <strong>“Cross Site Scripting (XSS)”</strong> and then select “Reflected XSS Attack”</p>
<p>i) Fill up the “Enter your three digit access code:” with <code>111&lt;script&gt; var test = "username=John Smith; expires=Thu, 18 Dec 2013 12:00:00 UTC; path=/";alert(test)&lt;/script&gt;</code></p>
<blockquote>
<p>Observe that you’ve successfully executed a XSS attack on the vulnerable website.</p>
</blockquote>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/congrats.png" alt="enter image description here"></p>
</li>
<li>
<p>Simulating <strong>DOS Attack:</strong></p>
<p>Run following script in your bash shell</p>
<pre><code>COUNT=0; while true; do echo $COUNT; curl -I 'http://&lt;cloudfront endpoint&gt;/WebGoat/attack?Screen=360466308&amp;menu=5' --cookie 'JSESSIONID=&lt;replace this web cookie value – check your web browser cookie&gt;'; COUNT=$((COUNT+1)); done
</code></pre>
<p><img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/DDOS.png" alt="enter image description here"></p>
</li>
</ol>
<blockquote>
<p><strong>NOTE:</strong> Scroll down the page and you will able to get the JsessionID value</p>
</blockquote>
<ol start="12">
<li>Check <a href="https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#metricsV2:graph=~%28metrics~%28~%28~%27WAF~%27BlockedRequests~%27WebACL~%27SecurityAutomationsMaliciousRequesters~%27Rule~%27SecurityAutomationsHttpFloodRule%29~%28~%27...~%27SecurityAutomationsSqlInjectionRule%29~%28~%27...~%27SecurityAutomationsXssRule%29%29~view~%27timeSeries~stacked~false~region~%27us-east-1~stat~%27Sum~period~300~start~%27-P3D~end~%27P0D%29;namespace=WAF;dimensions=Rule,WebACL">AWS WAF ACL metric</a> to observe total number of blocks<br>
<img src="https://raw.githubusercontent.com/jeankoay88/EdgeServicesWorkshop/master/Images/CloudWatch.png" alt="enter image description here"></li>
</ol>

