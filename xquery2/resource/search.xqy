xquery version "1.0-ml";

(:~
 Resource Search
 Draws a blank search form
 Renders a Search result
:)

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";

import module namespace v-mob = "http://framework/view/v-mob" at "/view/v-mob.xqy";

import module namespace h = "helper.xqy" at "/lib/rewrite/helper.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

(: Include this in all scripts returning HTML5 so that empty tags are not collapsed :)
declare option xdmp:output "method=html";

(: Request fields :)
declare variable $term as xs:string? := xdmp:get-request-field("term", ());
declare variable $phrase as xs:string := xdmp:get-request-field("phrase", "off");

(: Search API options :)
declare variable $options :=
    <options xmlns="http://marklogic.com/appservices/search">
        <concurrency-level>8</concurrency-level>
        <debug>0</debug>
        <page-length>10</page-length>
        <search-option>score-logtfidf</search-option>
        <quality-weight>1.0</quality-weight>
        <return-constraints>false</return-constraints>
        <!-- Turning off the things we don't use -->
        <return-facets>false</return-facets>
        <return-qtext>false</return-qtext>
        <return-query>false</return-query>
        <return-results>true</return-results>
        <return-metrics>false</return-metrics>
        <return-similar>false</return-similar>
        <searchable-expression>//SPEECH</searchable-expression>
        <sort-order direction="descending">
            <score/>
        </sort-order>
        <term apply="term">
            <!-- "" $term returns no results -->
            <empty apply="no-results" />
            <!-- Not sure why this isn't a default -->
            <term-option>case-insensitive</term-option>
        </term>
        <grammar>
            <quotation>"</quotation>
            <implicit>
                <cts:and-query strength="20" xmlns:cts="http://marklogic.com/cts"/>
            </implicit>
            <starter strength="30" apply="grouping" delimiter=")">(</starter>
            <starter strength="40" apply="prefix" element="cts:not-query">-</starter>
            <joiner strength="10" apply="infix" element="cts:or-query" tokenize="word">OR</joiner>
            <joiner strength="20" apply="infix" element="cts:and-query" tokenize="word">AND</joiner>
            <joiner strength="30" apply="infix" element="cts:near-query" tokenize="word">NEAR</joiner>
            <joiner strength="30" apply="near2" consume="2" element="cts:near-query">NEAR/</joiner>
            <joiner strength="50" apply="constraint">:</joiner>
            <joiner strength="50" apply="constraint" compare="LT" tokenize="word">LT</joiner>
            <joiner strength="50" apply="constraint" compare="LE" tokenize="word">LE</joiner>
            <joiner strength="50" apply="constraint" compare="GT" tokenize="word">GT</joiner>
            <joiner strength="50" apply="constraint" compare="GE" tokenize="word">GE</joiner>
            <joiner strength="50" apply="constraint" compare="NE" tokenize="word">NE</joiner>
        </grammar>
        <!-- Custom rendering code for "Snippet" -->
        <transform-results apply="snippet" ns="http://framework/lib/l-util" at="/lib/l-util.xqy" />
    </options>;

(:~
 Convert search result to HTML5
 @param results -- search:result from search:response
 @return an unordered list of search results
:)
declare function local:transform-results($results as element(search:result)*) as element(ul)? {
    if($results) then
        (: Search results :)
        <ul data-role="listview" data-inset="true"  data-dividertheme="a">
        {
            (: Fore each result :)
            for $r in $results
            
            (: 
             Obtain play details from smaller /REFDOC static rendering
             see _scripts/createrefplays.xqy
            :)
            let $uri := fn:string($r/@uri)
            let $refdoc := fn:doc(fn:concat("/ref/",$uri))
            let $title := $refdoc//TITLE/text()
            let $id := fn:string($refdoc/REFPLAY/@id)
            
            (: the speech :)
            let $s := $r//SPEECH
            
            (: Extract position references for act and scene from @path :)
            let $path := fn:substring-after( fn:string($r/@path) , "/PLAY/" )
            let $act := fn:substring-before( fn:substring-after($path, "ACT[") , "]")
            let $scene := fn:substring-before( fn:substring-after($path, "SCENE[") , "]")
            let $speech := fn:substring-before( fn:substring-after($path, "SPEECH[") , "]")
            
            return
            (
                (: Title of Play :)
                <li data-role="list-divider">{$title}</li>,
                
                (: This list item is a link to the speech in the /play... REST link :)
                <li>
                    <a class="searchlink" 
                       href="/play/{$id}/act/{$act}/scene/{$scene}/speech/{$speech}">
                        {
                            <h3>{$s/SPEAKER/node()}</h3>,
                            
                            <div style="margin-left:20px;">
                            {
                                for $n in $s/node()[ fn:local-name(.) = ("LINE","STAGEDIR") ]
                                return
                                    typeswitch($n) 
                                    (: Ignore, kindof redundant :)
                                    case element(SPEAKER) return
                                        ()
                                    (: convert lines to divs :)
                                    case element(LINE) return
                                        <div>{$n/node()}</div>
                                    (: Italic stage directions :)
                                    case element(STAGEDIR) return
                                        <div><em>{$n/node()}</em></div>
                                    default return
                                        $n
                            }        
                            </div>
                                    
                        }
                        <p class="ui-li-aside">
                            {text{"Act:",$act,"Scene:",$scene,"Speech",$speech}}
                        </p>
                    </a>    
                </li>
            )
        }
        </ul>
    else
        ()
};

(:~
 Renders search page
 Responds to both GET an POST commands
 @return HTML5
:)
declare function local:get() as item()*  {
    v-mob:render(
        $cfg:TITLE,
        $cfg:TITLE,
        (
        
        
        <div>
            <p>
                <!-- Search Form -->
                <form action="/search" method="get" data-transition="fade" class="ui-body ui-body-b ui-corner-all">
                    <fieldset >
                        <label for="search-basic">Search all lines:</label>
                        <input type="search" name="term" id="term" value="{$term}" data-theme="b" />    
                    </fieldset>
                    <div data-role="fieldcontain">
                        <label for="slider2">Phrase search:</label>
                        <select name="phrase" id="phrase" data-role="slider" >
                            <option value="off">
                                Off
                            </option>
                            <option value="on">
                                {
                                    (: Dynamic inline attribute of the option element :)
                                    if($phrase eq "on") then 
                                        attribute selected {"selected"} 
                                    else 
                                        ()
                                }
                                On
                            </option>
                        </select>
                    </div>
                    <button type="submit" data-theme="b" data-transition="fade">Submit</button>
                </form>
            </p>
            <br/>
            <p>
            {
                (: Search Results Area :)
                
                (: 
                 Modify the typed search term.  
                 Add Quotes if the $phrase flag is "on"
                 If the term is empty sequence, use ""
                :)
                let $searchTerm := 
                    if(fn:exists($term)) then 
                        if($phrase eq "on" and fn:not( fn:starts-with($term,'"') and fn:ends-with($term,'"'))) then
                            fn:concat('"',$term,'"')
                        else
                            $term
                    else 
                        ""
                return
                
                    (: 
                      Think Functionally ...
                      XQuery invokes passes the evaluation of search:search
                      to transform-results
                    :) 
                    
                    (: transform results into HTML5 :)
                    local:transform-results( 
                        (: execute the search with the Search API :)
                        search:search($searchTerm, $options)//search:result 
                    )
            }
            </p>
        </div>
        
        
        
        
        )
    )
};

(: rewrite library handler function pointer based on action HTTP field :)
try          { xdmp:apply( h:function() ) }
catch ( $e ) {  h:error( $e ) }