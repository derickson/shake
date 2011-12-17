xquery version "1.0-ml" ;

(:~
 Rewriter function
 THE URL that an incoming HTTP request should be rewritten to
 @author David Erickson
 @see http://front2backdev.com
 @version 1.0
:)

import module namespace shake-r = "routes.xqy" at "/lib/rewrite/routes.xqy";
import module namespace shake = "http://framework/lib/config" at "/lib/config.xqy";

declare variable $REWRITE_LOG_LEVEL := "finer";

(: let rewrite library determine destination URL,
   use routes configuration in config lib :)
let $selected-url := shake-r:selectedRoute( $shake:ROUTES )
        
let $_ := xdmp:log( text{"Request recieved:", xdmp:get-request-url()} , $REWRITE_LOG_LEVEL)
let $_ := xdmp:log( text{"Rewrite decision:", $selected-url}, $REWRITE_LOG_LEVEL)

return
    $selected-url