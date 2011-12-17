xquery version "1.0-ml";

(: Home.  List all Shakespeare plays :)

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";

import module namespace h = "helper.xqy" at "/lib/rewrite/helper.xqy";
import module namespace v-mob = "http://framework/view/v-mob" at "/view/v-mob.xqy";

(: Don't forget to include this so script
   tags in the VIEW are not collapsed :)
declare option xdmp:output "method=html";

declare function local:get()  {
    v-mob:render(
        $cfg:TITLE,
        <ul data-role="listview" data-inset="true" data-filter="true">
        {
            (: Note this code is inefficient at scale because we
               are effectively retrieving the entire database
               to generate these links.  It's only about 8MB of data
               and it is coming out of cache, but maybe we can speed
               it up later
            :)
            for $play in /PLAY
            return
                <li>
                  <a href="/play/{fn:string($play/@id)}">
                    {$play/TITLE/text()}
                  </a>
                </li>
        }
        </ul>
    )
};

try          { xdmp:apply( h:function() ) }
catch ( $e ) {  h:error( $e ) }