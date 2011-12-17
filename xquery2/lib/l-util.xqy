xquery version "1.0-ml" ;

(:~  
 l-util.xqy
 Utility Code
:)

module namespace lu = "http://framework/lib/l-util";

import module namespace search="http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

(:~
 Custom snippeting function
 Returns the entire result SPEECH with highlighting
 @param result -- search result, which will be an element(SPEECH)
 @param ctsquery -- The highlight query in serialized XML form
 @return the computed and highlighted search snippet
:)
declare function lu:snippet(
    $result as node(),
    $ctsquery as schema-element(cts:query),
    $options as element(search:transform-results)?
) as element(search:snippet) {
    (: pass back a snippet element :)
    element search:snippet {
        cts:highlight(
            $result, 
            (: We need to constuct the query from the XML serialization of a cts:query :)
            cts:query($ctsquery), 
            <span style="background-color:yellow">{$cts:text}</span>
        )
    }
    
};