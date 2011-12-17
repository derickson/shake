xquery version "1.0-ml";

(: Play detail  :)

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";

import module namespace h =
    "helper.xqy" at "/lib/rewrite/helper.xqy";
import module namespace v-mob =
    "http://framework/view/v-mob" at "/view/v-mob.xqy";

(: Don't forget to include this so script
   tags in the VIEW are not collapsed :)
declare option xdmp:output "method=html";

declare function local:characters()  { 

    let $id := h:id()
    let $play := /PLAY[@id eq $id]
    let $title := fn:string-join((
            $play/TITLE/text(),
            "Characters"
        )," ")
    return
    v-mob:render(
        $cfg:TITLE,
            <p>
                <h2>{$title}</h2>
                <h3>DRAMATIS PERSONAE</h3>
                {
                for $node in $play/PERSONAE/node()
                return
                    typeswitch ($node)
                    case element(TITLE) return
                        ()
                    case element(PGROUP) return
                        <ul data-role="listview"  data-inset="true">
                        {
                            for $p in $node/PERSONA
                            let $name := $p/text()
                            return
                                <li data-theme="a">{$name}</li>,
                            for $d in $node/GRPDESCR
                            return
                                <li data-theme="a">{$d/text()}</li>
                        }
                        </ul>
                    case element(PERSONA) return
                    <ul data-role="listview"  data-inset="true">
                        {
                            let $p := $node
                            let $name := $p/text()
                            return
                                <li data-theme="a">{$name}</li>
                        }
                        </ul>
                    default return
                        ()
                }
            </p>
    )
};

declare function local:get()  {
    let $id := h:id()
    let $act := xdmp:get-request-field("act",())[1]
    let $scene := xdmp:get-request-field("scene",())[1]

    let $act := if($act castable as xs:int) then
                  xs:int($act)
                else ()
    let $scene := if($scene castable as xs:int) then
                    xs:int($scene)
                  else ()

    let $play := /PLAY[@id eq $id]

    return
    v-mob:render(
        $cfg:TITLE,
        (
            <p>
                <h2>{$play/TITLE/text()}</h2>
                {
                    if($act) then
                      <h3>{($play/ACT)[$act]/TITLE/text()}</h3>
                    else (),

                    if($act and $scene) then
                      <h3>
                        {(($play/ACT)[$act]/SCENE)[$scene]/TITLE/text()}
                      </h3>
                    else (),

                    if(fn:not( $act or $scene )) then
                        <ul data-role="listview" data-inset="true" >
                          <li>
                            <a href="/play/{$id}/characters">
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

            if($act and $scene) then (
                let $paging :=
                    <div data-role="controlgroup" data-type="horizontal">
                    {
                        if($scene eq 1 and $act eq 1) then
                            ()
                        else if( $scene eq 1 and fn:exists( ($play/ACT)[$act -1] )) then
                            <a data-icon="arrow-l" href="/play/{$id}/act/{$act -1}/scene/{ fn:count(($play/ACT)[$act -1]/SCENE) }" data-role="button">Previous Scene</a>
                        else
                            <a data-icon="arrow-l"   href="/play/{$id}/act/{$act}/scene/{$scene -1}" data-role="button">Previous Scene</a>,

                        <a  data-icon="grid" href="/play/{$id}" data-role="button">Back to Scene Selection</a>,    

                        if( fn:count(($play/ACT)[$act]/SCENE) gt $scene ) then
                            <a  data-icon="arrow-r"  href="/play/{$id}/act/{$act}/scene/{$scene +1}" data-role="button">Next Scene</a>
                        else if( fn:exists( ($play/ACT)[$act +1] )) then
                            <a  data-icon="arrow-r"  href="/play/{$id}/act/{$act +1}/scene/1" data-role="button">Next Scene</a>
                        else
                            ()
                    }
                    </div>
                return (

                    $paging,

                    for $node in (($play/ACT)[$act]/SCENE)[$scene]/node()
                    return
                        typeswitch ($node)
                        case element(TITLE) return
                            <p><strong>{$node/text()}</strong></p>
                        case element(STAGEDIR) return
                            <p><em>{$node/text()}</em></p>
                        case element(SPEECH) return
                            <div class="ui-body ui-body-b"
                                 style="margin:20px 0px;">
                            {
                                $node/SPEAKER/text(),
                                <div style="margin-left:20px;">{
                                    for $line in $node/LINE/text()
                                    return
                                        <div>{$line}</div>
                                }
                                </div>
                            }

                            </div>
                        default return
                            ()

                    ,

                    $paging
                )

            )
            else
                <ul data-role="listview"  data-inset="true" >
                {
                    for $act at $a in $play/ACT
                    return
                    (
                        <li data-role="list-divider">{$act/TITLE/text()}</li>,

                        for $scene at $s in $act/SCENE
                        return
                            <li data-theme="c">
                                <a href="/play/{$id}/act/{$a}/scene/{$s}">
                                    {$scene/TITLE/text()}
                                </a>
                            </li>
                    )
                }
                </ul>
        )
    )
};

try          { xdmp:apply( h:function() ) }
catch ( $e ) {  h:error( $e ) }