xquery version "1.0-ml" ;

import module namespace shake-r =
    "routes.xqy" at "/lib/rewrite/routes.xqy";
import module namespace shake =
    "http://framework/lib/config" at "/lib/config.xqy";

    (: let rewrite library determine destination URL,
       use routes configuration in config lib :)
    let $selected-url    :=
            shake-r:selectedRoute( $shake:ROUTES )
    return
            $selected-url