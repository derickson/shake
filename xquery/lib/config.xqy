xquery version "1.0-ml" ;

(:  config.xqy
    This library module holds configuration
    variables for the application
:)

module  namespace cfg = "http://framework/lib/config";

(:  The rewrite library route configuration
    For documentation see: https://github.com/dscape/rewrite
:)
declare variable $ROUTES :=
    <routes>
        <root>home#get</root>
        <get path="play/:id">
          <to>play#get</to></get>
        <get path="play/:id/characters">
          <to>play#characters</to></get>
        <get path="play/:id/act/:act">
          <to>play#get</to></get>
        <get path="play/:id/act/:act/scene/:scene">
          <to>play#get</to></get>
    </routes>;

declare variable $TITLE := "Mobile Shakespeare";