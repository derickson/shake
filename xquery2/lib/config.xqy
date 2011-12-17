xquery version "1.0-ml" ;

(:~ 
 Configuration Variables
 This library module holds configuration
 variables for the application
:)

module  namespace cfg = "http://framework/lib/config";

(:~
 The rewrite library route configuration
 @see https://github.com/dscape/rewrite
:)
declare variable $ROUTES :=
    <routes>
        <root>home#home</root>
        
        <get path="plays"><to>play#list</to></get>
        <get path="play/:id"><to>play#scene</to></get>
        <get path="play/:id/characters"><to>play#characters</to></get>
        <get path="play/:id/act/:act"><to>play#scene</to></get>
        <get path="play/:id/act/:act/scene/:scene"><to>play#scene</to></get>
        <get path="play/:id/act/:act/scene/:scene/speech/:speech"><to>play#scene</to></get>
        
        <get path="search"><to>search#get</to></get>
        <post path="search"><to>search#get</to></post>
    </routes>;

declare variable $TITLE := "Mobile Shakespeare";