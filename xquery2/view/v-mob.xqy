xquery version "1.0-ml";

(:~
 HTML5 Template using JQuery Mobile
 XQuery adaptation Public Domain.
   jQuery and jQuery Mobile: MIT/GPL license
 @author David Erickson
 @see http://www.front2backdev.com
 @version 1.1
:)

module namespace v-mob = "http://framework/view/v-mob";

(: Include this in all scripts returning HTML5 so that empty tags are not collapsed :)
declare option xdmp:output "method=html";

(:~
 JQuery Mobile Output Template
 @param pagetitle -- the HTML head title
 @param title -- The title text to be displayed on the page
 @param html  -- HTML5 nodes to put in the body
 @return HTML5 formatted data, including DOCTYPE and response content header
:)
declare function v-mob:render(
    $pagetitle as xs:string,
    $title as xs:string,
    $html as node()*
) as item()* {
    
    xdmp:set-response-content-type("text/html"),
    '<!DOCTYPE html>',
    <html>
        <head>
            <title>{$pagetitle}</title>
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <link href='http://fonts.googleapis.com/css?family=Aguafina+Script|Vast+Shadow' rel='stylesheet' type='text/css'/>
            <link rel="stylesheet" href="/css/mobshake-jm.min.css"/>
            <link rel="stylesheet" href="http://code.jquery.com/mobile/1.0rc2/jquery.mobile.structure-1.0rc2.min.css"/>
            <link rel="stylesheet" href="/css/mobshake.css" />
            <script src="http://code.jquery.com/jquery-1.6.4.min.js"></script>
            <script src="http://code.jquery.com/mobile/1.0rc2/jquery.mobile-1.0rc2.min.js"></script>
        </head>
        <body> 
            <div id="page" data-role="page" data-theme="a"  data-dividertheme="a">
                <!-- Semantic Header -->
                <header>
                    <div data-role="header">
                        <!-- Back Button -->
                        <a data-rel="back"
                           data-icon="back"
                           data-iconpos="notext"
                           data-transition="slide"
                           data-direction="reverse">Back</a>
                        <!-- Header Title -->
                        <h1>{$title}</h1>
                        <!-- Home Button -->
                        <a href="/"
                           data-icon="home"
                           data-iconpos="notext"
                           data-transition="fade">Home</a>
                    </div><!-- /header -->
                </header>
                
                <div id="mobshake" data-role="content">
                    {$html}
                </div><!-- /content -->
            </div><!-- /page -->
        </body>
    </html>
};