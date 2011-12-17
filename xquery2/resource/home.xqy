xquery version "1.0-ml";

(:~
 Resource Home
 Menu for actions possible with this app 
:)

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";

import module namespace v-mob = "http://framework/view/v-mob" at "/view/v-mob.xqy";

import module namespace h = "helper.xqy" at "/lib/rewrite/helper.xqy";

(: Include this in all scripts returning HTML5 so that empty tags are not collapsed :)
declare option xdmp:output "method=html";

(:~
 Render Home page
 @return home page HTML5
:)
declare function local:home() as item()*  {
    v-mob:render(
        $cfg:TITLE,
        "",
        <div id="homepage">
            <h1>Mobile Shakespeare</h1>
            <div id="play-search" data-role="controlgroup" data-type="horizontal" >
                <a data-role="button" data-transition="fade" href="plays">Plays</a>
                <a data-role="button"  data-transition="fade" href="search">Search</a>
            </div> 
        </div>
    )
};

(: rewrite library handler function pointer based on action HTTP field :)
try          { xdmp:apply( h:function() ) }
catch ( $e ) {  h:error( $e ) }