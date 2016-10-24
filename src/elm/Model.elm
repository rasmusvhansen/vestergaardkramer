module Model exposing (..)


type alias Wish =
    { id : Maybe String
    , title : String
    , description : String
    , taken : Bool
    }


type alias WishId =
    String
