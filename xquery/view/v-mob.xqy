xquery version "1.0-ml";

module namespace v-mob = "http://framework/view/v-mob";

(:  Stick this at the top of any module that generates HTML so that
    empty tags don't get truncated to non-empty tags :)
declare option xdmp:output "method=html";

(:
    HTML5 Template using JQuery Mobile
    @author Dave http://www.front2backdev.com
    XQuery adaptation Public Domain.
        jQuery and jQuery Mobile: MIT/GPL license
:)

(:
    JQuery Mobile Output Template
    $title -- The html head title of the page
    $html  -- HTML5 nodes to put in the body
:)
declare function v-mob:render(
    $title as xs:string,
    $html as node()*
) {

xdmp:set-response-content-type("text/html"),
'<!DOCTYPE html>',
<html>
    <head>
        <title>{$title}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="stylesheet" href="http://code.jquery.com/mobile/1.0/jquery.mobile-1.0.min.css" />
        <script type="text/javascript" src="http://code.jquery.com/jquery-1.6.4.min.js"></script>
        <script type="text/javascript" src="http://code.jquery.com/mobile/1.0/jquery.mobile-1.0.min.js"></script>
    </head>
    <body> 

        <div data-role="page" data-theme="b">

            <div data-role="header">
                <a data-rel="back"
                   data-icon="back"
                   data-iconpos="notext"
                   data-transition="slide"
                   data-direction="reverse">Back</a>
                <h1>{$title}</h1>
                <a href="/"
                   data-icon="home"
                   data-iconpos="notext"
                   data-transition="fade">Home</a>
            </div><!-- /header -->

            <div data-role="content">
                {$html}
            </div><!-- /content -->

        </div><!-- /page -->

    </body>
</html>
};