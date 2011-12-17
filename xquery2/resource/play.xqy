xquery version "1.0-ml";

(:~ 
 Resource Play
 Lists plays
 Lists the Acts and Scenes of a play
 Lists the characters in a play
 Renders a Scene of a play
:)

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";

import module namespace v-mob = "http://framework/view/v-mob" at "/view/v-mob.xqy";

import module namespace h = "helper.xqy" at "/lib/rewrite/helper.xqy";

(: Include this in all scripts returning HTML5 so that empty tags are not collapsed :)
declare option xdmp:output "method=html";

(:~
 Render list of plays
 @return HTML5
:)
declare function local:list() as item()* {
    v-mob:render(
        $cfg:TITLE,
        $cfg:TITLE,
        <ul data-role="listview" 
            data-inset="true" 
            data-filter="true"  
            data-dividertheme="a" >
        {
            <li data-role="list-divider">His complete works:</li>,
       
            (: 
             This code is accessing a rendered view of reference 
             data which has been serialized as /REFPLAY documents.
             As the data is 100% static we can get away with this.
             We could render the whole page, but that would be boring.
             See _scripts/createrefplays.xqy
            :)
            for $play in /REFPLAY
            order by $play/SORTTITLE ascending 
            return
                <li>
                    <a href="/play/{fn:string($play/@id)}" data-transition="fade">
                        {$play/TITLE/text()}
                    </a>
                </li>
        }
        </ul>
    )
};

(:~
 Render list of characters
 Request Field -- "id" has the play id (Mandatory)
 @return HTML5
:)
declare function local:characters() as item()* { 
    (: the play id :)
    let $id := h:id()
    let $play := /PLAY[@id eq $id]
    let $title := fn:string-join((
            $play/TITLE/text(),
            "Characters"
        )," ")
        
    return
    v-mob:render(
        $cfg:TITLE,
        $cfg:TITLE,
            <p>
                <h2>{$title}</h2>
                <h3>DRAMATIS PERSONAE</h3>
                {
                (: PERSONAE is the section of XML for the DRAMATIS PERSONAE :)
                for $node in $play/PERSONAE/node()
                return
                    typeswitch ($node)
                    (: Ignore the TITLE, which just has DRAMATIS PERSONAE :)
                    case element(TITLE) return
                        ()
                    (: A a group of character names :)
                    case element(PGROUP) return
                        <ul data-role="listview"  data-inset="true">
                        {
                            (: list the persona in the group :)
                            for $p in $node/PERSONA
                            let $name := $p/text()
                            return
                                <li data-theme="d">{$name}</li>,
                                
                            (: then list the droup descriptions :)
                            for $d in $node/GRPDESCR
                            return
                                <li data-theme="c">{$d/text()}</li>
                        }
                        </ul>
                    (: characters not in a group ge their own list of 1 :)
                    case element(PERSONA) return
                        <ul data-role="listview"  data-inset="true">
                        {
                            let $p := $node
                            let $name := $p/text()
                            return
                                <li data-theme="d">{$name}</li>
                        }
                        </ul>
                    default return
                        ()
                }
            </p>
    )
};

(:~
 Render A scene of a play or the list of scenes
 Request Field -- "id" has the play id (Mandatory)
 Request Field -- "act" has the play id (Optional)
 Request Field -- "scene" has the play id (Optional)
 Request Field -- "speech" has the play id (Optional)
 HTTP Param -- ""
 @return HTML5
:)
declare function local:scene() as item()*  {
    (: get HTTP Request Fields :)
    let $id := h:id()
    let $act := xdmp:get-request-field("act",())[1]
    let $scene := xdmp:get-request-field("scene",())[1]
    let $speech := xdmp:get-request-field("speech",())[1]

    (: check that the act and scene values are of type xs:int? :)
    let $act := if($act castable as xs:int) then
                  xs:int($act)
                else ()
    let $scene := if($scene castable as xs:int) then
                    xs:int($scene)
                  else ()

    (: get the play :)
    let $play := /PLAY[@id eq $id]

    return
    v-mob:render(
        $cfg:TITLE,
        $cfg:TITLE,
        (
            (: Speech Button Javascript :)
            if(fn:exists($speech)) then
                <script type="text/javascript">
                /* <![CDATA[ */
                jQuery("#scrollbtn").live('click',function() {
                    var target;
                    // if there's an element with id 'current_user'
                    if ($("#scrolltarget").length > 0) {
                    // find this element's offset position
                    target = $("#scrolltarget").get(0).offsetTop;
                    return $.mobile.silentScroll(target); 
                  }
                });
                /* ]]> */
                </script>
            else (),
        
            <p>
                <h2>{$play/TITLE/text()}</h2>
                {
                    (: Act Name :)
                    if($act) then
                        <h3>
                        {($play/ACT)[$act]/TITLE/text()}
                        </h3>
                    else (),

                    (: Act and Scene Names :)
                    if($act and $scene) then
                        <h3>
                        {(($play/ACT)[$act]/SCENE)[$scene]/TITLE/text()}
                        </h3>
                    else (),

                    (: If listing of scenes, Character button :)
                    if(fn:not( $act or $scene )) then
                        <ul data-role="listview" data-inset="true" >
                          <li>
                            <a href="/play/{$id}/characters" data-transition="fade">
                              Characters
                              <span class="ui-li-count">
                                {fn:count($play/PERSONAE/PERSONA)}
                              </span>
                            </a>
                          </li>
                        </ul>
                    else
                        ()
                }
            </p>,

            (:
             ACT and SCENE specified by HTTP Request field
             render the scene 
            :)
            if($act and $scene) then (
                (: creating links for paging between scenes :)
                let $paging :=
                    <div data-role="controlgroup" data-type="vertical">
                    {
                        if($scene eq 1 and $act eq 1) then
                            ()
                        else if( $scene eq 1 and fn:exists( ($play/ACT)[$act -1] )) then
                            <a data-icon="arrow-l" 
                               href="/play/{$id}/act/{$act -1}/scene/{ fn:count(($play/ACT)[$act -1]/SCENE) }" 
                               data-role="button" 
                               data-transition="fade">
                                Previous Scene
                           </a>
                        else
                            <a data-icon="arrow-l"
                               href="/play/{$id}/act/{$act}/scene/{$scene -1}" 
                               data-role="button" 
                               data-transition="fade">
                                Previous Scene
                            </a>,

                        <a data-icon="grid" 
                           href="/play/{$id}" 
                           data-role="button"
                           data-transition="fade">
                            Scene List
                        </a>,    

                        if( fn:count(($play/ACT)[$act]/SCENE) gt $scene ) then
                            <a data-icon="arrow-r"
                               href="/play/{$id}/act/{$act}/scene/{$scene +1}" 
                               data-role="button" 
                               data-transition="fade">
                                Next Scene
                            </a>
                        else if( fn:exists( ($play/ACT)[$act +1] )) then
                            <a data-icon="arrow-r"
                               href="/play/{$id}/act/{$act +1}/scene/1" 
                               data-role="button" 
                               data-transition="fade">
                                Next Scene
                            </a>
                        else
                            ()
                    }
                    </div>
                    
                    
                return (
                    (: 
                     If a speech has been specified (from a search result) 
                     Render a button which will scroll to that speech with
                     JavaScript
                    :)
                    if(fn:exists($speech)) then
                        <button id="scrollbtn" 
                            data-theme="b" 
                            data-icon="arrow-d" data-iconpos="bottom">Scroll to the Speech {$speech}</button>
                    else
                        (),
                    
                    (: the paging link :)    
                    $paging,

                    (: counter for speech ids :)
                    let $x := 0 
                    (: Loop through all child nodes of the scene :)
                    for $node in (($play/ACT)[$act]/SCENE)[$scene]/node()
                    return
                        typeswitch ($node)
                        case element(TITLE) return
                            <p><strong>{$node/text()}</strong></p>
                        (: Stage Directions in Italics :)
                        case element(STAGEDIR) return
                            <p><em>{$node/text()}</em></p>
                        (: A Speech :)
                        case element(SPEECH) return (
                            xdmp:set($x, $x + 1),
                        
                            <div class="ui-body ui-body-b"
                                 style="margin:20px 0px;">
                            {
                                (: 
                                 Make this the scroll target 
                                 if the counter matches 
                                :)
                                if(fn:string($x) eq fn:string($speech)) then
                                    attribute id {"scrolltarget"}
                                else
                                    (),
                                
                                (: Speaker and the Lines :)
                                $node/SPEAKER/text(),
                                <div style="margin-left:20px;">{
                                    for $line in $node/LINE/text()
                                    return
                                        <div>{$line}</div>
                                }
                                </div>
                            }

                            </div>
                        )
                        default return
                            ()

                    ,
                    (: the paging link, again :)  
                    $paging
                )

            )
            (: List the acts and scenes :)
            else
                <ul data-role="listview"  data-inset="true"  data-dividertheme="a">
                {
                    for $act at $a in $play/ACT
                    return
                    (
                        <li data-role="list-divider">{$act/TITLE/text()}</li>,

                        for $scene at $s in $act/SCENE
                        return
                            <li >
                                <a href="/play/{$id}/act/{$a}/scene/{$s}" data-transition="fade">
                                    {$scene/TITLE/text()}
                                </a>
                            </li>
                    )
                }
                </ul>
        )
    )
};

(: rewrite library handler function pointer based on action HTTP field :)
try          { xdmp:apply( h:function() ) }
catch ( $e ) {  h:error( $e ) }