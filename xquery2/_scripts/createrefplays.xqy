for $p in /PLAY
let $id := fn:string( $p/@id )
let $title := $p/TITLE/text()

let $sortTitle := fn:replace(   
                    fn:replace(
                        fn:replace( $title, "^The ", "")
                        ,"^ Tragedy of ","")
                    ,"^[A-Za-z]* Part of ","")

let $uri := fn:concat("/ref/",xdmp:node-uri($p))
return

xdmp:document-insert( $uri, element REFPLAY {
  attribute id {$id},
  element TITLE {$title},
  element SORTTITLE {$sortTitle}
})