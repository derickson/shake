for $p at $id in /PLAY
let $at := attribute id {$id}
return
xdmp:node-insert-child($p,$at)