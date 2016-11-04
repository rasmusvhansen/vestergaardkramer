module Model exposing (..)


type alias Person =
    String


type alias Wish =
    { id : Maybe String
    , title : String
    , description : String
    , taken : Bool
    , person : String
    }


type alias Route =
    { route : Maybe String
    , params : Maybe (List String)
    }


type alias WishId =
    String


type alias Model =
    { wishes : List Wish
    , wish : Maybe Wish
    , error : Maybe String
    , route : Route
    }


emptyModel : Model
emptyModel =
    initModel (Route Nothing Nothing) Nothing


initWish : Person -> Wish
initWish person =
    Wish Nothing "" "" False person


initModel : Route -> Maybe Wish -> Model
initModel route wish =
    Model [] wish Nothing route
