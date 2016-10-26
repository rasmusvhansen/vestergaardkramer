module Model exposing (..)


type alias Wish =
    { id : Maybe String
    , title : String
    , description : String
    , taken : Bool
    }


type alias Route =
    { route : Maybe String
    , params : Maybe (List String)
    }


type alias WishId =
    String


type alias Model =
    { wishes : List Wish
    , wish : Wish
    , error : Maybe String
    , route : Route
    }


emptyModel : Model
emptyModel =
    initModel (Route Nothing Nothing)


initModel : Route -> Model
initModel route =
    Model [] { title = "", description = "", taken = False, id = Nothing } Nothing route
