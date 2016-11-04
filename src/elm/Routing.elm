port module Routing exposing (..)

import Model exposing (..)
import Messages exposing (..)
import Commands exposing (..)
import Navigation
import String


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    case result of
        Ok route ->
            case ( route.route, route.params ) of
                ( Just "wishes", Just (person :: rest) ) ->
                    ( initModel route (Just (initWish person)), getWishes (Debug.log "person" person) )

                ( Just "wishadmin", Just (person :: rest) ) ->
                    ( initModel route (Just (initWish person)), getWishes (Debug.log "person" person) )

                _ ->
                    ( initModel route Nothing, Cmd.none )

        Err _ ->
            ( model, Cmd.none )


urlParser : Navigation.Parser (Result String Route)
urlParser =
    Navigation.makeParser (fromUrl << .hash)


fromUrl : String -> Result String Route
fromUrl url =
    let
        parts =
            String.split "/" (String.dropLeft 2 (Debug.log "url" url))
    in
        Ok (Route (List.head parts) (List.tail parts))
